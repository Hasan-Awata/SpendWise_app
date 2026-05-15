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
        public decimal AmountInSp { get; set; } = 0.0m;
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        public int TransactionCategoryId { get; set; } = -1;
        public int TransactionTagId { get; set; } = -1;
        public int SavingGoalId { get; set; } = -1;   
        //public FixedExpense? FixedExpense { get; set; }
        //public FixedIncome? FixedIncome { get; set; }
        //public Debt? Debt { get; set; }
        public int IncomeId { get; set; } = -1;
        public int ExpenseId { get; set; } = -1;

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; } // Addition or Deduction from the balance

        public Transaction(int transactionId, int userId, string title, string description, int walletId, decimal amount, decimal amountInSp, DateTime transactionDate, enTransactionType transactionType)
        {
            TransactionId = transactionId;
            UserId = userId;
            Title = title;
            Description = description;
            WalletId = walletId;
            Amount = amount;
            AmountInSp = amountInSp;
            TransactionDate = transactionDate;
            TransactionType = transactionType;
        }
        public Transaction() { }
    }
}
