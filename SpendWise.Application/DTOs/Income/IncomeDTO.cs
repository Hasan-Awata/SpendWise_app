using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Income
{
    public class IncomeDTO
    {

        [Required(ErrorMessage = "Income ID is required!")]
        public int Id { get; set; }

        [Required(ErrorMessage = "Please enter a title for this income!")]
        [StringLength(100, ErrorMessage = "Title cannot exceed 100 characters!")]
        public string Title { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters!")]
        public string Description { get; set; } = string.Empty;

        [Required(ErrorMessage = "Please select the income type!")]
        public enIncomeType enIncomeType { get; set; }

        [Required(ErrorMessage = "Enter the amount of your income")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }

        public DateTime? Repetition { get; set; }


    }
}
