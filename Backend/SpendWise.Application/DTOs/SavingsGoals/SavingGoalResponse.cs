using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.SavingsGoals
{
    public class SavingGoalResponse
    {
        public int GoalID { get; set; }
        public int UserID { get; set; }

        public string Title { get; set; } = string.Empty;

        public decimal TargetAmount { get; set; }

        public decimal CurrentAmount { get; set; }

        public DateTime DeadlineDate { get; set; }
        public int CurrencyId { get; set; }

        public SavingGoalResponse() { }
        public SavingGoalResponse(int goalID, int userID, string title, decimal targetAmount, decimal currentAmount, DateTime deadlineDate,int currencyId)
        {
            GoalID = goalID;
            UserID = userID;
            Title = title;
            TargetAmount = targetAmount;
            CurrentAmount = currentAmount;
            DeadlineDate = deadlineDate;
            CurrencyId = currencyId;
        }
        public SavingGoalResponse(SpendWise.Domain.Entities.SavingGoal savingGoals) {
             this.GoalID= savingGoals.GoalID;
            this.DeadlineDate = savingGoals.DeadlineDate;
            this.UserID = savingGoals.UserID;
            this.CurrentAmount = savingGoals.CurrentAmount;
            this.Title = savingGoals.Title;
            this.TargetAmount = savingGoals.TargetAmount;
            this.CurrencyId = savingGoals.CurrencyId;

        
        }

    }
}
