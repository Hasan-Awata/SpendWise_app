using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Transaction
{
    public class TransactionResponse
    {
        public int TransactionId { get; set; } = -1;
        public int UserId { get; set; } = -1;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        //public IncomeResponse? IncomeResponse { get; set; }
        //public ExpenseResponse? ExpenseResponse { get; set; }
        //public DeptResponse? DeptResponse { get; set; }
        //public SavingGoalResponse? SavingGoalResponse { get; set; }
    }
}
