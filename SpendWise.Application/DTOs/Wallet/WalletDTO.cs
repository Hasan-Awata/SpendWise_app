using SpendWise.Application.DTOs.Currency;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.NewFolder
{
    public  class WalletDTO
    {
        public int WalletId { get; set; } = -1;

        [Required(ErrorMessage = "Please enter the currencyDto")]
        public CurrencyDTO Currency { get; set; } = new CurrencyDTO();

        [Range(0, double.MaxValue, ErrorMessage = "Balance cannot be negative!")]
        public decimal Balance { get; set; }

        [Required(ErrorMessage = "Wallet must belong to a user!")]
        public int UserId { get; set; }
    }
}
