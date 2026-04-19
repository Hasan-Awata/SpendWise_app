using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Currency
{
    public class CurrencyResponse
    {
        public int Id { get; set; }
        public string CurrencyName { get; set; } = string.Empty;
        public decimal LiveValue { get; set; }
    }
}
