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
        public int CategoryId { get; set; } = -1;
        public decimal PercentageLimit { get; set; }
        public decimal PercentageProgress { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
        public CategoryBudgetResponse(Domain.Entities.CategoryBudget categoryBudget)
        {
            CategoryBudgetId = categoryBudget.CategoryBudgetId;
            UserId = categoryBudget.UserId;
            CategoryId = categoryBudget.CategoryId;
            PercentageLimit = categoryBudget.PercentageLimit;
            PercentageProgress = categoryBudget.PercentageProgress;
            StartDate = categoryBudget.StartDate;
            EndDate = categoryBudget.EndDate;
            IsActive = categoryBudget.IsActive;
        }
        public CategoryBudgetResponse() { }

    }
}
