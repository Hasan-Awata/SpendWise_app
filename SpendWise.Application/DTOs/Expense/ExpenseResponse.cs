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
        public WalletResponse Wallet { get; set; } = new WalletResponse();
        public TagResponse? ExpenseTag { get; set; }
        public string Products { get; set; } = string.Empty; // JSON as a string
        public CategoryResponse Category { get; set; } = new CategoryResponse();
    }
}
