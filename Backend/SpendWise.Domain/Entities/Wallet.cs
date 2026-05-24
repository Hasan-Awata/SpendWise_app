using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Wallet
    {
        public int WalletId { get; set; }
        public int CurrencyId { get; set; }
        public decimal Balance { get; set; }
        public int UserId { get; set; }
        public bool IsSaved { get; set; }

        //Add object (Currencies) => here and into Constructor
        public Wallet(int walletId, int currencyId, decimal balance, int userId, bool isSaved)
        {
            WalletId = walletId;
            CurrencyId = currencyId;
            Balance = balance;
            UserId = userId;
            IsSaved = isSaved;
            
        }
        public Wallet(int walletId, decimal balance, int userId, bool isSaved)
        {
            WalletId = walletId;
            Balance = balance;
            UserId = userId;
            IsSaved = isSaved;
        }
        public Wallet() { }

    }
}
