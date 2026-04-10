using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Currency
    {
        public int Id { get; set; }
        public string CurrencyName { get; set; } = string.Empty;
        public decimal LiveValue { get; set; }
        public Currency(int id, string currencyName)
        {
            this.Id = id;
            this.CurrencyName = currencyName;
        }

        public Currency() { }
    }
}
