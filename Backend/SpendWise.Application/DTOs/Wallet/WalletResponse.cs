using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Currency;

namespace SpendWise.Application.DTOs.Wallet
{
    public class WalletResponse
    {
        public int WalletId { get; set; }
        public int CurrencyId { get; set; }
        public decimal Balance { get; set; }
        public int UserId { get; set; }
        public bool IsSaved { get; set; }

        public WalletResponse(int walletId, int currencyId, decimal balance, int userId, bool isSaved)
        {
            WalletId = walletId;
            CurrencyId = currencyId;
            Balance = balance;
            UserId = userId;
            IsSaved = isSaved;
        }
    }
}
