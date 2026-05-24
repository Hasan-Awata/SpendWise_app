using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.ExchangeRate
{
    public interface IExchangeRateService
    {
        public Task<decimal> NormalizeFromSyrianPund(string currencySymbol, string rateType, decimal amount);
        public Task<decimal> NormalizeToSyrianPound(string currencySymbol, string region, string rateType, decimal amount);
    }
}
