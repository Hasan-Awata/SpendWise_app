using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Domain.Enums;

namespace SpendWise.Domain.Entities
{
    public class Transaction
    {
        public int TransactionId { get; set; } = -1;
        public int UserId { get; set; } = -1;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int WalletId { get; set; } 
        public decimal Amount { get; set; } = 0.0m;
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        public int TransactionCategoryId { get; set; }
        public int TransactionTagId { get; set; }
        public SavingGoal? SavingGoal { get; set; }
        //public FixedExpense? FixedExpense { get; set; }
        //public FixedIncome? FixedIncome { get; set; }
        //public Debt? Debt { get; set; }
        public Income? Income { get; set; }
        public Expense? Expense { get; set; }

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; } // Addition or Deduction from the balance

        public Transaction(int transactionId, int userId, string title, string? description, int walletId, decimal amount, DateTime transactionDate, int transactionCategoryId, int transactionTagId, SavingGoal? savingGoal, Income? income, Expense? expense, enTransactionType transactionType)
        {
            TransactionId = transactionId;
            UserId = userId;
            Title = title;
            Description = description;
            WalletId = walletId;
            Amount = amount;
            TransactionDate = transactionDate;
            TransactionCategoryId = transactionCategoryId;
            TransactionTagId = transactionTagId;
            SavingGoal = savingGoal;
            Income = income;
            Expense = expense;
            TransactionType = transactionType;
        }
        public Transaction() { }
    }
}
