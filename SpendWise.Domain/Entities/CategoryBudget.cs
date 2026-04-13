using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class CategoryBudget
    {
        public int CategoryBudgetId { get; set; }
        public int UserId { get; set; }
        public Category Category { get; set; } = new Category();
        public decimal PercentageLimit { get; set; }
        public decimal PercentageProgress { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
       
    }
}
