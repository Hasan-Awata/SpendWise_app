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
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; } = 0.0m;
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; }
        public int? ExpenseId { get; set; } = -1;
        public int? SharedExpenseId { get; set; } = -1; 
        public int? GoalId { get; set; } = -1;
        public int? ObligationId { get; set; } = -1;
       
        // Transaction mode is specified here: Add, Edit, Delete
         public enTransactionMode TransactionMode { get; set; }

        public Transaction(int transactionId, int userId, string description, decimal amount,
            DateTime transactionDate, enTransactionType transactionType, enTransactionMode transactionMode)
        {
            TransactionId = transactionId;
            UserId = userId;
            Description = description;
            Amount = amount;
            TransactionDate = transactionDate;
            TransactionType = transactionType;
            TransactionMode = transactionMode;
        }

    }
}
