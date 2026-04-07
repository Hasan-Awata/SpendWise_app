using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.SavingGoals
{
    public interface ISavingGoals
    {
        // Get a specific goal by its ID
        public Task<SavingGoalsResponse?> GetGoalByIdAsync(int goalId);

        // Get all goals for a specific user
        public Task<IEnumerable<SavingGoalsResponse>>? GetAllUserGoalsAsync(int userId);

        // Add a new savings goal
        public Task<bool> AddGoalAsync(SavingGoalsDTO goalDto);

        // Update an existing goal
        public Task<bool> UpdateGoalAsync(int goalId, SavingGoalsDTO goalDto);

        // Delete a goal
        public Task<bool> DeleteGoalAsync(int goalId);

        // Check if a goal exists
        public Task<bool> GoalExistsAsync(int goalId);
        Task<IEnumerable<SavingGoalsResponse>> GetAchievedGoalsAsync(int userId);
    }
}
