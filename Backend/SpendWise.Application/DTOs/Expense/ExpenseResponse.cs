using SpendWise.Application.DTOs.Category;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.DTOs.Wallet;
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
        public bool IsOverLimit { get; set; }
    }
}
