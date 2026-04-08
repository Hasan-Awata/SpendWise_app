using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.SavingGoals
{
    public interface ISavingGoalService
    {
        // Get a specific goal by its ID
        public Task<SavingGoalResponse?> GetGoalByIdAsync(int goalId);

        // Get all goals for a specific user
        public Task<IEnumerable<SavingGoalResponse>>? GetAllUserGoalsAsync(int userId);

        // Add a new savings goal
        public Task<int> AddGoalAsync(SavingGoalDTO goalDto);

        // Update an existing goal
        public Task<bool> UpdateGoalAsync(int goalId, SavingGoalDTO goalDto);

        // Delete a goal
        public Task<bool> DeleteGoalAsync(int goalId);

        // Check if a goal exists
        public Task<bool> GoalExistsAsync(int goalId);
        Task<IEnumerable<SavingGoalResponse>> GetAchievedGoalsAsync(int userId);
    }
}
