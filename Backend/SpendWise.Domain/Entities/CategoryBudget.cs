using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace SpendWise.Domain.Entities
{
    public class CategoryBudget
    {
        public int CategoryBudgetId { get; set; }
        public int UserId { get; set; }
        public Category Category { get; set; } = new Category();
        public int CategoryId { get; set; }
        public decimal PercentageLimit { get; set; }
        public decimal PercentageProgress { get; set; }
        public decimal MoneyLimit { get; set; }
        public decimal SpendingProgress {  get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
        public CategoryBudget(int categoryBudgetId, int userId, int categoryId, decimal percentageLimit, decimal percentageProgress, decimal moneyLimit, decimal spendingProgress, DateTime startDate, DateTime endDate, bool isActive)
        {
            CategoryBudgetId = categoryBudgetId;
            UserId = userId;
            CategoryId = categoryId;
            PercentageLimit = percentageLimit;
            PercentageProgress = percentageProgress;
            MoneyLimit = moneyLimit;
            SpendingProgress = spendingProgress;
            StartDate = startDate;
            EndDate = endDate;
            IsActive = isActive;
        }
        public CategoryBudget(int categoryBudgetId, int userId, int categoryId, decimal percentageLimit, decimal percentageProgress, DateTime startDate, DateTime endDate, bool isActive)
        {
            CategoryBudgetId = categoryBudgetId;
            UserId = userId;
            CategoryId = categoryId;
            PercentageLimit = percentageLimit;
            PercentageProgress = percentageProgress;
            StartDate = startDate;
            EndDate = endDate;
            IsActive = isActive;
        }
        public CategoryBudget() { }
    }
}
