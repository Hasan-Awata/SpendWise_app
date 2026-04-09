using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Currency
{
    public class CurrencyDTO
    {
        public int CurrencyId { get; set; }

        [Required(ErrorMessage = "Please enter the currency name")]
        public string CurrencyName { get; set; } = string.Empty;
        public decimal LiveValue { get; set; }
    }
}
