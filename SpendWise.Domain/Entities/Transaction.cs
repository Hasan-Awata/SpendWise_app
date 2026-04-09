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
        public Wallet Wallet { get; set; } = new Wallet();
        public decimal Amount { get; set; } = 0.0m;
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        public Category? TransactionCategory { get; set; }
        public Tag? TransactionTag { get; set; }
        public int? SavinGoalId { get; set; }
        public int? FixedExpenseId { get; set; }
        public int? FixedIncomeId { get; set; }
        public int? DebtId { get; set; }
        public Income? Income { get; set; }
        public Expense? Expense { get; set; }

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; } // Addition or Deduction from the balance

    }
}
