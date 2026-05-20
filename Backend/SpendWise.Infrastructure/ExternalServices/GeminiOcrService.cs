using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.Entities;
using SpendWise.Domain.ProcessingResults;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using static System.Net.Mime.MediaTypeNames;

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
                                      "title": "store name + the Purchases type",
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

            int maxRetries = 3;
            int delayMilliseconds = 2000;

            for (int attempt = 1; attempt <= maxRetries; attempt++)
            {
                try
                {
                    var response = await _httpClient.PostAsJsonAsync(url, requestBody);

                    if (((int)response.StatusCode == 503 || (int)response.StatusCode == 504) && attempt < maxRetries)
                    {
                        await Task.Delay(delayMilliseconds);
                        delayMilliseconds *= 2;
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
                catch (HttpRequestException ex)
                {
                    if (attempt < maxRetries)
                    {
                        await Task.Delay(delayMilliseconds);
                        delayMilliseconds *= 2;
                        continue;
                    }
                    return new OcrResult { IsSuccess = false, ErrorMessage = $"Network exception: {ex.Message}" };
                }
            }

            return new OcrResult { IsSuccess = false, ErrorMessage = "Gemini API error: Timeout: couldn't connect to model" };
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

                text = text.Trim().TrimStart('`');
                if (text.StartsWith("json")) text = text[4..];
                text = text.TrimEnd('`').Trim();

                using var resultDoc = JsonDocument.Parse(text);
                var root = resultDoc.RootElement;

                var products = new List<Product>();

                if (root.TryGetProperty("items", out var items))
                {
                    foreach (var item in items.EnumerateArray())
                    {
                        // 1. Manually resolve the quantity safeguard from the element
                        int finalizedQuantity = 1; // Default fallback if missing completely

                        if (item.TryGetProperty("quantity", out var qtyProp))
                        {
                            if (qtyProp.ValueKind == JsonValueKind.Number)
                            {
                                // Handles 1.00 or 2.5 safely by reading as double first, then casting to int
                                finalizedQuantity = (int)qtyProp.GetDouble();
                            }
                            else if (qtyProp.ValueKind == JsonValueKind.String)
                            {
                                string qtyStr = qtyProp.GetString() ?? "1";

                                // Try parsing standard integer strings like "1"
                                if (int.TryParse(qtyStr, out int parsedInt))
                                {
                                    finalizedQuantity = parsedInt;
                                }
                                // Try parsing string decimals like "1.00"
                                else if (double.TryParse(qtyStr, out double parsedDouble))
                                {
                                    finalizedQuantity = (int)parsedDouble;
                                }
                            }
                        }

                        // 2. Safely extract Name and Price properties
                        string productName = item.TryGetProperty("name", out var nameProp)
                            ? nameProp.GetString() ?? "Unknown Item"
                            : "Unknown Item";

                        decimal productPrice = decimal.Zero;
                        if (item.TryGetProperty("price", out var priceProp))
                        {
                            if (priceProp.ValueKind == JsonValueKind.Number)
                            {
                                productPrice = priceProp.GetDecimal();
                            }
                            else if (priceProp.ValueKind == JsonValueKind.String && decimal.TryParse(priceProp.GetString(), out var parsedPrice))
                            {
                                productPrice = parsedPrice;
                            }
                        }

                        // 3. Assemble and add to list
                        var product = new Product
                        (
                            productName,
                            finalizedQuantity,
                            productPrice
                        );

                        products.Add(product);
                    }
                }

                // Helper function to safely read root decimals
                decimal GetDecimalValue(JsonElement element, string propertyName)
                {
                    if (element.TryGetProperty(propertyName, out var prop))
                    {
                        if (prop.ValueKind == JsonValueKind.Number)
                        {
                            return prop.GetDecimal();
                        }
                        if (prop.ValueKind == JsonValueKind.String && decimal.TryParse(prop.GetString(), out var parsedDecimal))
                        {
                            return parsedDecimal;
                        }
                    }
                    return decimal.Zero;
                }

                // Helper function to safely read root dates
                DateTime GetDateTimeValue(JsonElement element, string propertyName)
                {
                    if (element.TryGetProperty(propertyName, out var prop))
                    {
                        if (prop.ValueKind == JsonValueKind.Number)
                        {
                            return DateTime.Now;
                        }

                        if (prop.ValueKind == JsonValueKind.String)
                        {
                            string dateStr = prop.GetString() ?? string.Empty;

                            if (string.IsNullOrWhiteSpace(dateStr) ||
                                dateStr.Equals("null", StringComparison.OrdinalIgnoreCase))
                            {
                                return DateTime.Now;
                            }

                            if (DateTime.TryParse(dateStr, out var parsedDate))
                            {
                                return parsedDate;
                            }
                        }
                    }
                    return DateTime.Now;
                }

                return new OcrResult
                {
                    IsSuccess = true,
                    RawText = root.TryGetProperty("raw_text", out var raw) ? raw.GetString() ?? text : text,
                    Title = root.TryGetProperty("title", out var title) ? title.GetString() ?? "New billl": "New bill",
                    Products = products,
                    Subtotal = GetDecimalValue(root, "subtotal"),
                    Tax = GetDecimalValue(root, "tax"),
                    Total = GetDecimalValue(root, "total"),
                    Date = GetDateTimeValue(root, "date"),
                };
            }
            catch (Exception ex)
            {
                return new OcrResult { IsSuccess = false, ErrorMessage = $"Failed to parse Gemini response: {ex.Message}" };
            }
        }
    }
}
