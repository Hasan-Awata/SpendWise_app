using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Currency;

namespace SpendWise.Application.DTOs.Wallet
{
    public  class WalletResponse
    {
        public int WalletId { get; set; }
        public CurrencyResponse Currency { get; set; } = new CurrencyResponse();
        public decimal Balance { get; set; }
        public int UserId { get; set; }
        public bool IsSaved { get; set; }
    }
}
