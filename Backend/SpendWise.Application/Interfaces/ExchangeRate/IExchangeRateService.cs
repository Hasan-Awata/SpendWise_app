using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.ExchangeRate
{
    public interface IExchangeRateService
    {
        public Task<decimal> NormalizeToSyrianPound(string currencySymbol, string region, string rateType, decimal amount);
        public Task<decimal> NormalizeFromSyrianPound(string currencySymbol, string region, string rateType, decimal amount);
        public Task<decimal> NormaliezTwoCurrencies(string fromCurrencySymbol, string fromRegion, string toCurrencySymbol, string toRegion, string rateType, decimal amount);
    }
}
