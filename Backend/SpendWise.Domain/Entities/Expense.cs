using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Expense
    {
        public int ExpenseId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Products { get; set; } = string.Empty;
        public int ExpenseTagId { get; set; }
        public int CategoryId { get; set; } 
        public int WalletId { get; set; } 
        public Transaction LinkedTransaction { get; set; } = new Transaction();
        public DateTime Date { get; set; }
        public Expense(int expenseId, int userId, string title, decimal amount, string products, int expenseTagId, int categoryId, int walletId, Transaction linkedTransaction, DateTime date)
        {
            ExpenseId = expenseId;
            UserId = userId;
            Title = title;
            Amount = amount;
            Products = products;
            ExpenseTagId = expenseTagId;
            CategoryId = categoryId;
            WalletId = walletId;
            LinkedTransaction = linkedTransaction;
            Date = date;
        }
        public Expense() { }
    }
}
