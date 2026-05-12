using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class SavingGoal
    {
        public int GoalID { get; set; }
        public int UserID { get; set; }

        public string Title { get; set; } = string.Empty;

        public decimal TargetAmount { get; set; }

        public decimal CurrentAmount { get; set; }

        public DateTime DeadlineDate { get; set; }
        public bool IsAchieved { get; set; }
        public SavingGoal() { }
        public SavingGoal(int goalID, int userID, string title, decimal targetAmount, decimal currentAmount, DateTime deadlineDate)
        {
            GoalID = goalID;
            UserID = userID;
            Title = title;
            TargetAmount = targetAmount;
            CurrentAmount = currentAmount;
            DeadlineDate = deadlineDate;
            IsAchieved = (currentAmount == targetAmount);
        }
    }
}
