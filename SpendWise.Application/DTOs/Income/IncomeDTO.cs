using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Income
{
    public class IncomeDTO
    {
        [Required(ErrorMessage = "Owner ID is required!")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Please enter a title for this income!")]
        [StringLength(100, ErrorMessage = "Title cannot exceed 100 characters!")]
        public string Title { get; set; } = string.Empty;

        [Required(ErrorMessage = "Please enter the wallet's id that you want to deduct from")]
        public int WalletId { get; set; }

        [Required(ErrorMessage = "Enter the amount of your income")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }

        [Required(ErrorMessage ="Please enter the date of the transaction")]
        public DateTime Date { get; set; }
        
        public int? TagId { get; set; } = -1;
        public string Description { get; set; } = string.Empty;
    }
}
