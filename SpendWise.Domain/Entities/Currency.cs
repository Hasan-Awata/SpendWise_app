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
        public Currency(int id, string currencyName, Decimal livevalue = 1.000m)
        {
            this.Id = id;
            this.CurrencyName = currencyName;
            this.LiveValue = livevalue;
        }

        public Currency() { }
    }
}
