using System;

namespace SpendWise.Domain.Entities
{
    public class FixedIncome
    {
        public int FixedIncomeId { get; set; }
        public int UserId { get; set; }
        public int WalletId { get; set; } 
        public string Title { get; set; }
        public decimal Amount { get; set; }
        public bool IsMonthly { get; set; }
        public bool IsActive { get; set; }
        public int? Days { get; set; }
        public DateTime? LastTime { get; set; } 

        public FixedIncome(
            int fixedIncomeId,
            int userId,
            int walletId,
            string title,
            decimal amount,
            bool isMonthly,
            bool isActive,
            int? days,
            DateTime? lastTime)
        {
            FixedIncomeId = fixedIncomeId;
            UserId = userId;
            WalletId = walletId;
            Title = title;
            Amount = amount;
            IsMonthly = isMonthly;
            IsActive = isActive;
            Days = days;
            LastTime = lastTime;
        }
    }
}