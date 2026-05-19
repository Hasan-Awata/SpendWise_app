using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

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
            var response = await _httpClient.PostAsJsonAsync(url, requestBody);

            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync();
                return new OcrResult { IsSuccess = false, ErrorMessage = $"Gemini API error: {error}" };
            }

            var json = await response.Content.ReadAsStringAsync();
            return ParseGeminiResponse(json);
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
                if (root.TryGetProperty("items", out var items))
                    foreach (var item in items.EnumerateArray())
                        lines.Add(item.GetRawText());

                return new OcrResult
                {
                    IsSuccess = true,
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
