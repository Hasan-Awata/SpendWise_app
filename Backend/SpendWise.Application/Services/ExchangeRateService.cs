using Microsoft.Extensions.Caching.Memory;
using SpendWise.Application.Interfaces.ExchangeRate;
using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json;

namespace SpendWise.Application.Services
{
    public class ExchangeRateService: IExchangeRateService
    {
        private readonly HttpClient _httpClient;
        private readonly IMemoryCache _cache;

        public ExchangeRateService(HttpClient httpClient, IMemoryCache cache)
        {
            _httpClient = httpClient;
            _cache = cache;
        }

        private async Task<decimal> GetExchangeRateAsync(string currencyKey, string rateType)
        {

            // Create a unique name for this specific cached item
            string cacheKey = $"ExchangeRate_{currencyKey}_{rateType}";

            // 1. Check if the rate is already saved in the server's memory
            if (_cache.TryGetValue(cacheKey, out decimal cachedRate))
            {
                return cachedRate; // Return instantly without hitting the API
            }

            // 2. If it's not in the cache, make the actual HTTP call
            var response = await _httpClient.GetAsync("https://sse.sp-today.com/snapshot");
            response.EnsureSuccessStatusCode();

            var jsonString = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(jsonString);

            var root = document.RootElement;

            if (root.TryGetProperty("data", out var dataElement) &&
                dataElement.TryGetProperty("currencies", out var currenciesElement) &&
                currenciesElement.TryGetProperty(currencyKey, out var currencyElement) &&
                currencyElement.TryGetProperty(rateType, out var rateElement))
            {
                var rate = rateElement.GetDecimal();

                // 3. Save the fetched rate into the cache for 1 hour
                _cache.Set(cacheKey, rate, TimeSpan.FromHours(1));

                return rate;
            }

            throw new Exception($"Could not retrieve the {rateType} rate for {currencyKey}.");
        }

        public async Task<decimal> NormalizeToSyrianPound(string currencySymbol, string region, string rateType, decimal amount)
        {
            string currencyKey = currencySymbol.ToUpper() + ":" + region.ToLower();
            
            decimal exchangeRate = await GetExchangeRateAsync(currencyKey , rateType);

            decimal amountInSP = exchangeRate / amount; 

            return Math.Round(amountInSP / 5, MidpointRounding.AwayFromZero) * 5;
        }
    }
}
