using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.SavingGoals
{
    public interface ISavingGoalRepository
    {
        public Task<SavingGoal?> GetGoalByIdAsync(int goalId);
        public Task<IEnumerable<SavingGoal>>? GetAllUserGoalsAsync(int userId);
        public Task<int> AddGoalAsync(SavingGoal goal);
        public Task<bool> UpdateGoalAsync(SavingGoal ubdatedGoal);
        public Task<bool> DeleteGoalAsync(int goalId);
        public Task<bool> GoalExistsAsync(int goalId);
        public Task<IEnumerable<SavingGoal>> GetAchievedGoalsAsync(int userId);
    }
}
