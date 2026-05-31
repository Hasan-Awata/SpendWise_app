using System;

namespace SpendWise.Application.DTOs.FixedIncome
{
    public class FixedIncomeResponse
    {
        public int FixedIncomeId { get; set; }
        public int UserId { get; set; }
        public int TagId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public bool IsMonthly { get; set; }
        public bool IsActive { get; set; }
        public int Days { get; set; }
        public DateTime LastTime { get; set; }

      //  public string TagName { get; set; } = string.Empty;
    }
}