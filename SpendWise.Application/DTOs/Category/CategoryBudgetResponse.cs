using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Category
{
    public class CategoryBudgetResponse
    {
        public int CategoryBudgetId { get; set; }
        public int UserId { get; set; }
        public CategoryDTO Category { get; set; } = new CategoryDTO();
        public decimal PercentageLimit { get; set; }
        public decimal PercentageProgress { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }

    }
}
