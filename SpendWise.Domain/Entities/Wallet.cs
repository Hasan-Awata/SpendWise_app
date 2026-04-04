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
        public User user { get; set; } = null!;

        //Add object (Currencies) => here and into Constructor
        public Wallet(int walletId, int currencyId, decimal balance, int userId, User user)
        {
            WalletId = walletId;
            CurrencyId = currencyId;
            Balance = balance;
            UserId = userId;
            this.user = user;
        }

        // Parameterless constructor for EF Core or other frameworks
        public Wallet() { }

    }
}
