using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Category
{
    public class CategoryBudgetDTO
    {
        public int CategoryBudgetId { get; set; }
        public int UserId { get; set; }

        [Required]
        public int CategoryId { get; set; }

        [Required]
        public decimal PercentageLimit { get; set; }

        public decimal PercentageProgress { get; set; } = 0;

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
    }
}
