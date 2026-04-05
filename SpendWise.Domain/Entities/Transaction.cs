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
        public decimal Amount { get; set; } = 0.0m;
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; } // Expense or Income

        public Transaction(int transactionId, int userId, string title, string description, decimal amount,
            DateTime transactionDate, enTransactionType transactionType)
        {
            TransactionId = transactionId;
            UserId = userId;
            Title = title;
            Description = description;
            Amount = amount;
            TransactionDate = transactionDate;
            TransactionType = transactionType;
        }

    }
}
