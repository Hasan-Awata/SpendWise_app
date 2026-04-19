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
        public int TransactionId { get; set; } = -1;
        public int UserId { get; set; } = -1;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        // Process Id
        public int? IncomeId { get; set; }
        public int? FixedIncomeId { get; set; }
        public int? FixedExpenseId { get; set; }
        public int? SavingGoalId { get; set; }
        public int? DebtId { get; set; }
    }
}
