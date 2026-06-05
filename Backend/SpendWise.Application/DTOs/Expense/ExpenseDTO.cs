using SpendWise.Application.DTOs.Category;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Expense
{
    public class ExpenseDTO
    {
        public int ExpenseId { get; set; } = -1;

        [Required(ErrorMessage = "Owner ID is required!")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Please enter a title for this expense!")]
        [StringLength(100, ErrorMessage = "Title cannot exceed 100 characters!")]
        public string Title { get; set; } = string.Empty;

        [Required(ErrorMessage = "Please enter the wallet info for this expense")]
        public int WalletId { get; set; }

        [Required(ErrorMessage = "Please enter the expense category")]
        public int CategoryId { get; set; } 

        [Required(ErrorMessage = "Enter the amount of your income")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }

        [Required(ErrorMessage = "Please enter the date of the transaction")]
        public DateTime Date { get; set; }

        public int ExpenseTagId { get; set; } = -1;
        public string Description { get; set; } = string.Empty;
        public List<ProductDTO> Products { get; set; } = new();
    }
}
