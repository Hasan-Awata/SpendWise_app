using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Expense
{
    public class ExpenseResponse
    {
        public int ExpenseId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public int WalletId { get; set; }
        public DateTime Date { get; set; }
        public int ExpenseTagId { get; set; }
        public string Products { get; set; } = string.Empty; // JSON as a string
        public int CategoryId { get; set; }

        // Transaction Details
        public int TransactionId { get; set; }
        public string Description { get; set; } = string.Empty;
        public decimal AmountInSp { get; set; } = 0.0m;

        // Additional data (often assigned after initialization)
        public bool IsOverLimit { get; set; }
        public int CurrencyId { get; set; }

        public ExpenseResponse(SpendWise.Domain.Entities.Expense expense)
        {
            ExpenseId = expense.ExpenseId;
            UserId = expense.UserId;
            Title = expense.Title;
            Amount = expense.Amount;
            WalletId = expense.WalletId;
            Date = expense.Date;
            ExpenseTagId = expense.ExpenseTagId;
            Products = expense.Products;
            CategoryId = expense.CategoryId;
            CurrencyId = currencyId;

            TransactionId = expense.LinkedTransaction.TransactionId;
            Description = expense.LinkedTransaction.Description;
            AmountInSp = expense.LinkedTransaction.AmountInSp;
        }

    public ExpenseResponse() { }

    }

}
