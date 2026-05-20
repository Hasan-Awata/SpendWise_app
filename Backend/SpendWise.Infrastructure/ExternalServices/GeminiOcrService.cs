using Google.GenAI;
using Google.GenAI.Types;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.Entities;
using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Type = Google.GenAI.Types.Type;

namespace SpendWise.Application.Services
{
    public class GeminiOcrService : IOcrService
    {
        private Client _geminiClient;
        private readonly List<string> _apiKeys = new();
        private int _currentKeyIndex = 0;
        private const string ModelName = "gemini-2.5-flash";

        public class ReceiptItemDto
        {
            [JsonPropertyName("name")] public string Name { get; set; } = string.Empty;
            [JsonPropertyName("quantity")] public int Quantity { get; set; } = 1;
            [JsonPropertyName("price")] public decimal Price { get; set; }
        }

        public class ReceiptResponseDto
        {
            [JsonPropertyName("title")] public string Title { get; set; } = "New bill";
            [JsonPropertyName("date")] public string? Date { get; set; }
            [JsonPropertyName("items")] public List<ReceiptItemDto> Items { get; set; } = new();
            [JsonPropertyName("subtotal")] public decimal Subtotal { get; set; }
            [JsonPropertyName("tax")] public decimal Tax { get; set; }
            [JsonPropertyName("total")] public decimal Total { get; set; }
            [JsonPropertyName("raw_text")] public string RawText { get; set; } = string.Empty;
        }

        public GeminiOcrService(IConfiguration configuration)
        {
            // Bind the configuration JSON array directly into our local string list
            configuration.GetSection("Gemini:ApiKeys").Bind(_apiKeys);

            if (_apiKeys == null || _apiKeys.Count == 0)
            {
                throw new InvalidOperationException("Gemini configuration array 'ApiKeys' is missing or empty.");
            }

            // Initialize the base engine using the first available key slot
            _geminiClient = new Client(apiKey: _apiKeys[_currentKeyIndex]);
        }

        private void RotateApiKey()
        {
            if (_apiKeys.Count <= 1) return; // Nowhere to rotate if only one key exists

            _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.Count;

            // Re-instantiate the client on the fly with the next valid credential slot
            _geminiClient = new Client(apiKey: _apiKeys[_currentKeyIndex]);
        }

        public async Task<OcrResult> ProcessReceipt(byte[] imageBytes, string mimeType = "image/jpeg")
        {
            try
            {
                string systemInstructionsText = @"
                    Task: Act as a rigid data extraction processor for receipts.
                    Language Scope: English, Arabic, or mixed bilingual formats.
                    
                    Edge-Case Behavior Rules:
                    1. For 'raw_text': Transcribe every character visible line-by-line. Never truncate text.
                    2. For Arabic items: Extract text using native Arabic characters. Do not translate words to English.
                    3. Numeric Isolation: Strip all currency designations, text tokens, or symbols (e.g., 'SR', 'SAR', '$'). Extract pure numeric components.
                    4. Default Safeguards: If an item's quantity is illegible, default to 1. If date parsing fails, return null.
                    5. Final Price Calculation (Multi-Quantity): If an item has a quantity greater than 1, always populate the 'price' field with the FINAL computed line-item total (Quantity × Unit Price), not the single unit cost.";

                var config = new GenerateContentConfig
                {
                    ResponseMimeType = "application/json",
                    SystemInstruction = new Content
                    {
                        Parts = new List<Part> { Part.FromText(systemInstructionsText) }
                    },
                    ResponseSchema = new Schema
                    {
                        Type = Type.Object,
                        Properties = new Dictionary<string, Schema>
                        {
                            { "title", new Schema { Type = Type.String } },
                            { "date", new Schema { Type = Type.String } },
                            { "subtotal", new Schema { Type = Type.Number } },
                            { "tax", new Schema { Type = Type.Number } },
                            { "total", new Schema { Type = Type.Number } },
                            { "raw_text", new Schema { Type = Type.String } },
                            { "items", new Schema
                                {
                                    Type = Type.Array,
                                    Items = new Schema
                                    {
                                        Type = Type.Object,
                                        Properties = new Dictionary<string, Schema>
                                        {
                                            { "name", new Schema { Type = Type.String } },
                                            { "quantity", new Schema { Type = Type.Integer } },
                                            { "price", new Schema { Type = Type.Number } }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    Temperature = 0.1
                };

                var imagePart = Part.FromBytes(imageBytes, mimeType);
                var requestContent = new Content { Parts = new List<Part> { imagePart } };

                GenerateContentResponse? response = null;
                int waitingTime = 2000;

                for (int attempt = 1; attempt <= 3; attempt++)
                {
                    try
                    {
                        response = await _geminiClient.Models.GenerateContentAsync(
                            model: ModelName,
                            contents: requestContent,
                            config: config
                        );

                        if (response?.Candidates != null && response.Candidates.Count > 0)
                        {
                            break;
                        }
                    }
                    catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.TooManyRequests && attempt < 3)
                    {
                        // Target 429 errors specifically, swap the key pool right now
                        RotateApiKey();

                        // Optional: Reduce or skip waiting time since a fresh key has its own quota pool
                        await Task.Delay(500);
                    }
                    catch (Exception) when (attempt < 3)
                    {
                        // Fallback handling for network errors or transient timeouts
                        await Task.Delay(waitingTime);
                        waitingTime *= 2;
                    }
                }

                if (response?.Candidates == null || response.Candidates.Count == 0)
                {
                    return new OcrResult { IsSuccess = false, ErrorMessage = "Gemini processing failed after exhaustion of retries." };
                }

                string textResponse = response.Text;
                var extractedData = JsonSerializer.Deserialize<ReceiptResponseDto>(textResponse);

                if (extractedData == null)
                {
                    return new OcrResult { IsSuccess = false, ErrorMessage = "Failed to deserialize response object." };
                }

                return MapToDomainResult(extractedData);
            }
            catch (Exception ex)
            {
                return new OcrResult { IsSuccess = false, ErrorMessage = $"Gemini Critical Exception: {ex.Message}" };
            }
        }

        private OcrResult MapToDomainResult(ReceiptResponseDto dto)
        {
            var products = new List<Product>();
            foreach (var item in dto.Items)
            {
                products.Add(new Product(item.Name, item.Quantity, item.Price));
            }

            DateTime finalDate = DateTime.TryParse(dto.Date, out var parsedDate) ? parsedDate : DateTime.Now;

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
    }
}