using System;
using System.ComponentModel.DataAnnotations;

namespace SpendWise.Application.DTOs.FixedIncome
{
    public class FixedIncomeDTO
    {
        [Required(ErrorMessage = "User ID is required!")]
        public int UserId { get; set; }
        [Required(ErrorMessage = "Wallet ID is required!")]
        public int WalletId { get; set; }
        [Required(ErrorMessage = "Please enter a title for this fixed income!")]
        [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters!")]
        public string Title { get; set; } = string.Empty;
        [Required(ErrorMessage = "Enter the amount of your income")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }
        [Required(ErrorMessage = "Please specify if this is a monthly income.")]
        public bool IsMonthly { get; set; }
        public bool IsActive { get; set; } = true;
        [Range(1, 31, ErrorMessage = "Days must be between 1 and 31!")]
        public int? Days { get; set; }
         public DateTime? LastTime { get; set; }
    }
}