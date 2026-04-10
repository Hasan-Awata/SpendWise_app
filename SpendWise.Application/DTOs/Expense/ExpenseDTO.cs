using SpendWise.Application.DTOs.Category;
using SpendWise.Application.DTOs.NewFolder;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Income
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
        public WalletDTO Wallet { get; set; } = new WalletDTO();

        [Required(ErrorMessage = "Please enter the expense category")]
        public CategoryDTO Category { get; set; } = new CategoryDTO();

        [Required(ErrorMessage = "Enter the amount of your income")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }

        [Required(ErrorMessage = "Please enter the date of the transaction")]
        public DateTime Date { get; set; }

        public TagDTO? ExpenseTag { get; set; };
        public string Description { get; set; } = string.Empty;
        public string Products {  get; set; } = string.Empty; // JSON 
    }
}
