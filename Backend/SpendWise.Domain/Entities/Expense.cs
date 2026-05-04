using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Expense
    {
        public int ExpenseId { get; set; }
        public int UserId { get; set; }
        public decimal Amount { get; set; }
        public string Products { get; set; } = string.Empty;
        public int ExpenseTagId { get; set; }
        public int CategoryId { get; set; } 
        public int WalletId { get; set; } 
        public DateTime Date { get; set; }
        public Transaction LinkedTransaction { get; set; } = new Transaction();
        public Expense(int expenseId, int userId, decimal amount, string products, int expenseTagId, int categoryId, int walletId, DateTime date, Transaction linkedTransaction)
        {
            ExpenseId = expenseId;
            UserId = userId;
            Amount = amount;
            Products = products;
            ExpenseTagId = expenseTagId;
            CategoryId = categoryId;
            WalletId = walletId;
            Date = date;
            LinkedTransaction = linkedTransaction;
        }
        public Expense() { }
    }
}
