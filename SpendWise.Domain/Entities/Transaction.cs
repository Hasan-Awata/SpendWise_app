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

        public int? CategoryId { get; set; }
        public int? TagId { get; set; }
        public int? SavinGoalId { get; set; }
        public int? FixedExpenseId { get; set; }
        public int? FixedIncomeId { get; set; }
        public int? DebtId { get; set; }
        public int? IncomeId { get; set; }
        public int? ExpenseId { get; set; }

        // Transaction type is specified here:
        public enTransactionType TransactionType { get; set; } // Addition or Deduction from the balance

    }
}
