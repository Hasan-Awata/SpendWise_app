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

        // Transaction mode is specified here: Add, Edit, Delete
         public enTransactionMode TransactionMode { get; set; }

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; }
        public int RecordId { get; set; } = -1; // Refrencing to the record in the table that was specified in transaction type

        public Transaction(int transactionId, int userId, string title, string description, decimal amount, int recordId,
            DateTime transactionDate, enTransactionType transactionType, enTransactionMode transactionMode)
        {
            TransactionId = transactionId;
            UserId = userId;
            Title = title;
            Description = description;
            Amount = amount;
            RecordId = recordId;
            TransactionDate = transactionDate;
            TransactionType = transactionType;
            TransactionMode = transactionMode;
        }

    }
}
