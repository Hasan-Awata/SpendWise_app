using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Currency
{
    public class CurrencyDTO
    {
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Please select a valid currency.")]
        public int CurrencyId { get; set; } = -1;

        [Required(ErrorMessage = "Please enter the currency name")]
        public string CurrencyName { get; set; } = string.Empty;
        public decimal LiveValue { get; set; }
    }
}
