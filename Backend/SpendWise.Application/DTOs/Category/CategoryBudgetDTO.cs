using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Category
{
    public class CategoryBudgetDTO
    {
        public int CategoryBudgetId { get; set; }

        [Required(ErrorMessage = "Please enter the user id")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Please enter the category info of this budget")]
        public CategoryDTO Category { get; set; } = new CategoryDTO();

        [Required(ErrorMessage = "Please enter the consumption limit of this category")]
        public decimal PercentageLimit { get; set; }

        [Required(ErrorMessage = "Please enter the percentage of the money consumed in this category")]
        public decimal PercentageProgress { get; set; }

        [Required(ErrorMessage = "Please enter the date this budget started")]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "Please enter the date this budget supposed to end")]
        public DateTime EndDate { get; set; }

        [Required(ErrorMessage = "Enter the status of this budget")]
        public bool IsActive { get; set; }
    }
}
