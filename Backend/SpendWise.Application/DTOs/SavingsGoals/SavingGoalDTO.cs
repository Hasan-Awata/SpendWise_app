using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.SavingGoals
{
    public class SavingGoalDTO
    {

        [Required(ErrorMessage = "Title is required!")]
        [StringLength(150, ErrorMessage = "Title cannot exceed 150 characters.")]
        public string Title { get; set; } = string.Empty;
        [Required(ErrorMessage = "User ID is required!")]

        public int UserId { get; set; }
   


        [Required(ErrorMessage = "Target amount is required!")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Target amount must be greater than 0!")]
        public decimal TargetAmount { get; set; }

        [Required(ErrorMessage = "Current amount is required!")]
        [Range(0, double.MaxValue, ErrorMessage = "Current amount cannot be negative!")]
        public decimal CurrentAmount { get; set; }

        [Required(ErrorMessage = "Deadline date is required!")]
        [DataType(DataType.Date)]
        public DateTime DeadlineDate { get; set; }

       public int CurrencyId { get; set; }

    }
}
