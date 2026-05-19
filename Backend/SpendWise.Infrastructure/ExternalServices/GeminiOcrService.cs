using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace SpendWise.Application.Services
{
    public class GeminiOcrService : IOcrService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private const string Model = "gemini-2.5-flash";

        public GeminiOcrService(IConfiguration configuration, IHttpClientFactory httpClientFactory)
        {
            _apiKey = configuration["Gemini:ApiKey"]
                ?? throw new InvalidOperationException("Gemini:ApiKey is not configured.");
            _httpClient = httpClientFactory.CreateClient();
        }

        public async Task<OcrResult> ProcessReceipt(byte[] imageBytes, string mimeType = "image/jpeg")
        {
            var base64Image = Convert.ToBase64String(imageBytes);

            var requestBody = new
            {
                contents = new[]
                {
                new
                {
                    parts = new object[]
                    {
                        new
                        {
                            inline_data = new
                            {
                                mime_type = mimeType,
                                data = base64Image
                            }
                        },
                        new
                        {
                            text = """
                                Extract all text from this receipt accurately.
                                The receipt may be in English, Arabic, or both.
                                Return a JSON object with this exact structure:
                                {
                                  "store": "store name",
                                  "date": "date if present, else null",
                                  "items": [{ "name": "item name", "quantity": 1, "price": 0.00 }],
                                  "subtotal": 0.00,
                                  "tax": 0.00,
                                  "total": 0.00,
                                  "raw_text": "full verbatim text of the receipt"
                                }
                                Return only the JSON object, no markdown, no explanation.
                                """
                        }
                    }
                }
            }
            };

            var url = $"https://generativelanguage.googleapis.com/v1beta/models/{Model}:generateContent?key={_apiKey}";

            // Retrying logic in case the request failed the first time

            int maxRetries = 3;
            int delayMilliseconds = 2000; // Start with a 2-second delay

            for (int attempt = 1; attempt <= maxRetries; attempt++)
            {
                var response = await _httpClient.PostAsJsonAsync(url, requestBody);

                // If it's a 503, wait and try again
                if (((int)response.StatusCode == 503 || (int)response.StatusCode == 504) && attempt < maxRetries)
                {
                    await Task.Delay(delayMilliseconds);
                    delayMilliseconds *= 2; // Double the wait time (Exponential Backoff)
                    continue;
                }

                if (!response.IsSuccessStatusCode)
                {
                    var error = await response.Content.ReadAsStringAsync();
                    return new OcrResult { IsSuccess = false, ErrorMessage = $"Gemini API error: {error}" };
                }

                var json = await response.Content.ReadAsStringAsync();
                return ParseGeminiResponse(json);
            }

            return new OcrResult { IsSuccess = false, ErrorMessage = $"Gemini API error: Timeout: couldn't connect to model" };
        }

        private OcrResult ParseGeminiResponse(string json)
        {
            try
            {
                using var doc = JsonDocument.Parse(json);
                var text = doc.RootElement
                    .GetProperty("candidates")[0]
                    .GetProperty("content")
                    .GetProperty("parts")[0]
                    .GetProperty("text")
                    .GetString() ?? string.Empty;

                // Strip markdown fences if the model adds them despite instructions
                text = text.Trim().TrimStart('`');
                if (text.StartsWith("json")) text = text[4..];
                text = text.TrimEnd('`').Trim();

                using var resultDoc = JsonDocument.Parse(text);
                var root = resultDoc.RootElement;

                var lines = new List<string>();

                // Extract the entire "items" array directly as a single entry
                if (root.TryGetProperty("items", out var items))
                {
                    // Re-serializing the entire block minifies it, stripping all literal \n, \r, and internal spaces.
                    // Because it returns directly to the array as a base string, it won't contain escape slashes.
                    var cleanWholeJsonArray = JsonSerializer.Serialize(items, new JsonSerializerOptions
                    {
                        WriteIndented = false
                    });

                    lines.Add(cleanWholeJsonArray);
                }

                return new OcrResult
                {
                    IsSuccess = true,
                    // Preserves the full verbatim receipt text layout
                    RawText = root.TryGetProperty("raw_text", out var raw)
                        ? raw.GetString() ?? text
                        : text,
                    Lines = lines
                };
            }
            catch (Exception ex)
            {
                return new OcrResult { IsSuccess = false, ErrorMessage = $"Failed to parse Gemini response: {ex.Message}" };
            }
        }
    }
}
