using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Application.DTOs.Income;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Transaction
{
    public class TransactionResponse
    {
        // Main information
        public int TransactionId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; } = decimal.Zero;
        public decimal AmountInSp { get; set; } = 0.0m;
        public int WalletId { get; set; } = -1;
        public DateTime Date { get; set; }
        public enTransactionType TransactionType { get; set; }

        // Addetional Details
        public int TagId { get; set; } = -1;
        public int CategoryId { get; set; } = -1;

        // Process Id
        public int IncomeId { get; set; } = -1;
        public int ExpenseId { get; set; } = -1;
        public int FixedIncomeId { get; set; } = -1;
        public int FixedExpenseId { get; set; } = -1;
        public int SavingGoalId { get; set; } = -1;
        public int DebtId { get; set; } = -1;

        public TransactionResponse(SpendWise.Domain.Entities.Transaction transaction)
        {
            TransactionId = transaction.TransactionId;
            UserId = transaction.UserId;
            Title = transaction.Title;
            Description = transaction.Description;
            Amount = transaction.Amount;
            AmountInSp = transaction.AmountInSp;
            WalletId = transaction.WalletId;
            Date = transaction.TransactionDate;
            TransactionType = transaction.TransactionType;

            TagId = transaction.TransactionTagId;
            CategoryId = transaction.TransactionCategoryId;

            IncomeId = transaction.IncomeId;
            ExpenseId = transaction.ExpenseId;
            FixedIncomeId = transaction.FixedIncomeId;
            FixedExpenseId = transaction.FixedExpenseId;
            SavingGoalId = transaction.SavingGoalId;
            DebtId = transaction.DebtId;
        }

    }
}
