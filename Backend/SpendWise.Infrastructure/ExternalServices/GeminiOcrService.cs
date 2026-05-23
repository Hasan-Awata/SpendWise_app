using Google.GenAI;
using Google.GenAI.Types;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.Entities;
using SpendWise.Domain.ProcessingResults;
using System.Text.Json;
using System.Text.Json.Serialization;
using Type = Google.GenAI.Types.Type;

namespace SpendWise.Infrastructure.ExternalServices
{
    /// <summary>
    /// Processes receipt images using the Gemini Vision API with structured JSON output.
    /// Features: self-reported validity + confidence gating, API key rotation on 429s,
    /// per-request client instantiation for thread safety, and input validation guards.
    /// </summary>
    public class GeminiOcrService : IOcrService
    {
        // ── Constants ─────────────────────────────────────────────────────────────────

        private const string ModelName = "gemini-2.5-flash";
        private const int MaxImageSizeBytes = 10 * 1024 * 1024; // 10 MB
        private const int MaxRetryAttempts = 3;
        private const int BaseRetryDelayMs = 2000;
        private const double MinConfidenceScore = 0.7;

        private static readonly HashSet<string> AllowedMimeTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "image/jpeg",
            "image/png",
            "image/webp",
            "image/heic",
            "image/heif"
        };

        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            NumberHandling = JsonNumberHandling.AllowReadingFromString,
            PropertyNameCaseInsensitive = true
        };

        // ── State ─────────────────────────────────────────────────────────────────────

        private readonly List<string> _apiKeys;

        // Incremented atomically via Interlocked — safe across concurrent requests.
        private int _currentKeyIndex = 0;

        // ── DTOs ──────────────────────────────────────────────────────────────────────

        public class ReceiptItemDto
        {
            [JsonPropertyName("name")] public string Name { get; set; } = string.Empty;
            [JsonPropertyName("quantity")] public int Quantity { get; set; } = 1;
            [JsonPropertyName("price")] public decimal Price { get; set; }
        }

        public class ReceiptResponseDto
        {
            [JsonPropertyName("is_valid")] public bool IsValid { get; set; }
            [JsonPropertyName("confidence")] public double Confidence { get; set; }
            [JsonPropertyName("fail_reason")] public string? FailReason { get; set; }
            [JsonPropertyName("title")] public string Title { get; set; } = "New bill";
            [JsonPropertyName("date")] public string? Date { get; set; }
            [JsonPropertyName("items")] public List<ReceiptItemDto> Items { get; set; } = new();
            [JsonPropertyName("subtotal")] public decimal Subtotal { get; set; }
            [JsonPropertyName("tax")] public decimal Tax { get; set; }
            [JsonPropertyName("total")] public decimal Total { get; set; }
            [JsonPropertyName("raw_text")] public string RawText { get; set; } = string.Empty;
        }

        // ── Constructor ───────────────────────────────────────────────────────────────

        public GeminiOcrService(IConfiguration configuration)
        {
            var keys = new List<string>();
            configuration.GetSection("Gemini:ApiKeys").Bind(keys);

            if (keys == null || keys.Count == 0)
                throw new InvalidOperationException(
                    "Gemini configuration array 'Gemini:ApiKeys' is missing or empty.");

            _apiKeys = keys;
        }

        // ── Public API ────────────────────────────────────────────────────────────────

        public async Task<OcrResult> ProcessReceipt(byte[] imageBytes, string mimeType = "image/jpeg")
        {
            // ── Input validation ──────────────────────────────────────────────────────

            if (imageBytes == null || imageBytes.Length == 0)
                return Failure("Image data is empty.");

            if (imageBytes.Length > MaxImageSizeBytes)
                return Failure($"Image size ({imageBytes.Length / 1024 / 1024} MB) exceeds the allowed limit.");

            if (!AllowedMimeTypes.Contains(mimeType))
                return Failure($"Unsupported MIME type '{mimeType}'. Allowed: {string.Join(", ", AllowedMimeTypes)}.");

            try
            {
                var config = BuildGenerationConfig();
                var content = BuildRequestContent(imageBytes, mimeType);

                GenerateContentResponse? response = null;
                Exception? lastException = null;
                int retryDelayMs = BaseRetryDelayMs;

                // ── Retry loop ────────────────────────────────────────────────────────

                for (int attempt = 1; attempt <= MaxRetryAttempts; attempt++)
                {
                    // Fresh client per attempt — eliminates shared mutable client state.
                    using var client = new Client(apiKey: CurrentApiKey());

                    try
                    {
                        response = await client.Models.GenerateContentAsync(
                            model: ModelName,
                            contents: content,
                            config: config
                        );

                        if (response?.Candidates != null && response.Candidates.Count > 0)
                            break;

                        lastException = null;
                    }
                    catch (HttpRequestException ex)
                        when (ex.StatusCode == System.Net.HttpStatusCode.TooManyRequests && attempt < MaxRetryAttempts)
                    {
                        // 429: swap key immediately, then retry with a minimal delay.
                        RotateApiKey();
                        lastException = ex;
                        await Task.Delay(500);
                    }
                    catch (Exception ex) when (attempt < MaxRetryAttempts)
                    {
                        // Transient failure: exponential back-off.
                        lastException = ex;
                        await Task.Delay(retryDelayMs);
                        retryDelayMs *= 2;
                    }
                    catch (Exception ex)
                    {
                        lastException = ex;
                    }
                }

                // ── Response guards ───────────────────────────────────────────────────

                if (response?.Candidates == null || response.Candidates.Count == 0)
                {
                    string reason = lastException?.Message ?? "No candidates returned by the model.";
                    return Failure($"Gemini processing failed after {MaxRetryAttempts} attempts: {reason}");
                }

                var candidate = response.Candidates[0];

                if (candidate.FinishReason == FinishReason.Safety)
                    return Failure("The model's response was blocked by a safety filter.");

                string? textResponse = candidate.Content?.Parts?.FirstOrDefault()?.Text;

                if (string.IsNullOrWhiteSpace(textResponse))
                    return Failure("The model returned an empty response.");

                // ── Deserialize ───────────────────────────────────────────────────────

                var extractedData = JsonSerializer.Deserialize<ReceiptResponseDto>(textResponse, JsonOptions);

                if (extractedData == null)
                    return Failure("Failed to deserialize the model's JSON response.");

                // ── Validity & confidence gates ───────────────────────────────────────

                if (!extractedData.IsValid)
                {
                    string reason = string.IsNullOrWhiteSpace(extractedData.FailReason)
                        ? "The receipt could not be read clearly."
                        : extractedData.FailReason;

                    return Failure($"Invalid receipt: {reason}");
                }

                if (extractedData.Confidence < MinConfidenceScore)
                {
                    return Failure(
                        $"Receipt read confidence is too low ({extractedData.Confidence:P0}). " +
                        "Please retake the photo with better lighting and framing.");
                }

                return MapToDomainResult(extractedData);
            }
            catch (Exception ex)
            {
                return Failure($"Gemini critical exception: {ex.Message}");
            }
        }

        // ── Private helpers ───────────────────────────────────────────────────────────

        /// <summary>
        /// Returns the API key at the current index. Thread-safe read via Interlocked.
        /// </summary>
        private string CurrentApiKey()
        {
            int index = Interlocked.CompareExchange(ref _currentKeyIndex, 0, 0) % _apiKeys.Count;
            return _apiKeys[index];
        }

        /// <summary>
        /// Atomically advances the key pool index to the next slot.
        /// </summary>
        private void RotateApiKey()
        {
            if (_apiKeys.Count <= 1) return;
            Interlocked.Increment(ref _currentKeyIndex);
        }

        private static GenerateContentConfig BuildGenerationConfig()
        {
            const string systemInstructions = @"
                Task: Act as a rigid data extraction processor for receipts.
                Language Scope: English, Arabic, or mixed bilingual formats.

                Validity Assessment (evaluate FIRST before extracting anything):
                Set 'is_valid' to FALSE and populate 'fail_reason' if ANY of the following are true:
                - The image does not appear to be a receipt or invoice.
                - The image is too blurry, dark, cropped, or obstructed to read key fields (total, items, or date).
                - Less than 50% of the text is legible.
                - No line items or total amount can be determined with confidence.

                Set 'confidence' to a value between 0.0 and 1.0 reflecting your overall read quality:
                - 1.0  = perfectly clear; all fields extracted with certainty.
                - 0.7–0.99 = minor illegibility but core data is reliable.
                - Below 0.7 = significant uncertainty; set is_valid to false.

                If 'is_valid' is FALSE: still populate 'raw_text' with whatever is visible,
                but leave all numeric fields as 0 and 'items' as an empty array.

                Edge-Case Behavior Rules:
                1. For 'raw_text': Transcribe every character visible line-by-line. Never truncate text.
                2. For Arabic items: Extract text using native Arabic characters. Do not translate words to English.
                2. For Arabic-Indic numerals: Extract text using the Arabic numerals (Western Arabic Numerals).
                3. Numeric Isolation: Strip all currency designations, text tokens, or symbols (e.g., 'SR', 'SAR', '$'). Extract pure numeric components.
                4. Default Safeguards: If an item's quantity is illegible, default to 1. If date parsing fails, return null.
                5. Multi-Quantity Price Calculation: If an item has a quantity greater than 1, always populate the 'price' field with the FINAL computed line-item total (Quantity × Unit Price), not the single unit cost.
                6. Subtotal Calculation: Always use the subtotal written in the receipt. If the subtotal amount wasn't visible, it MUST always equal all products prices combined.
                7. Total Calculation: Always use the total written in the receipt. If the total amount wasn't visible, it MUST always equal (subtotal + tax).";

            return new GenerateContentConfig
            {
                ResponseMimeType = "application/json",
                Temperature = 0.1,
                SystemInstruction = new Content
                {
                    Parts = new List<Part> { Part.FromText(systemInstructions) }
                },
                ResponseSchema = new Schema
                {
                    Type = Type.Object,
                    Properties = new Dictionary<string, Schema>
                    {
                        { "is_valid",    new Schema { Type = Type.Boolean } },
                        { "confidence",  new Schema { Type = Type.Number  } },
                        { "fail_reason", new Schema { Type = Type.String  } },
                        { "title",       new Schema { Type = Type.String  } },
                        { "date",        new Schema { Type = Type.String  } },
                        { "subtotal",    new Schema { Type = Type.Number  } },
                        { "tax",         new Schema { Type = Type.Number  } },
                        { "total",       new Schema { Type = Type.Number  } },
                        { "raw_text",    new Schema { Type = Type.String  } },
                        {
                            "items", new Schema
                            {
                                Type  = Type.Array,
                                Items = new Schema
                                {
                                    Type = Type.Object,
                                    Properties = new Dictionary<string, Schema>
                                    {
                                        { "name",     new Schema { Type = Type.String  } },
                                        { "quantity", new Schema { Type = Type.Integer } },
                                        { "price",    new Schema { Type = Type.Number  } }
                                    }
                                }
                            }
                        }
                    }
                }
            };
        }

        private static Content BuildRequestContent(byte[] imageBytes, string mimeType)
        {
            return new Content
            {
                Parts = new List<Part>
                {
                    Part.FromBytes(imageBytes, mimeType),
                    Part.FromText("Extract all receipt data from this image.")
                }
            };
        }

        private static OcrResult MapToDomainResult(ReceiptResponseDto dto)
        {
            var products = dto.Items
                .Select(item => new Product(item.Name, item.Quantity, item.Price))
                .ToList();

            DateTime finalDate = DateTime.TryParse(dto.Date, out var parsedDate)
                ? parsedDate
                : DateTime.Now;

            return new OcrResult
            {
                IsSuccess = true,
                Title = dto.Title,
                RawText = dto.RawText,
                Subtotal = dto.Subtotal,
                Tax = dto.Tax,
                Total = dto.Total,
                Date = finalDate,
                Products = products
            };
        }

        private static OcrResult Failure(string message) =>
            new OcrResult { IsSuccess = false, ErrorMessage = message };
    }
}