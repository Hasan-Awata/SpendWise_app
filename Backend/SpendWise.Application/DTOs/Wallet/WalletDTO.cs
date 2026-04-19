using SpendWise.Application.DTOs.Currency;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Wallet
{
    public  class WalletDTO
    {
        public int WalletId { get; set; } = -1;

        [Required(ErrorMessage = "Please enter the currencyDto")]
        public int CurrencyId { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Balance cannot be negative!")]
        public decimal Balance { get; set; }

        [Required(ErrorMessage = "Wallet must belong to a user!")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Wallet must be specified as saved or not!")]
        public bool IsSaved { get; set; }
    }
}
