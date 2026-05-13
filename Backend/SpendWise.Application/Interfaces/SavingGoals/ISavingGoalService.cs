using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
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
        public Task<PagedResponse<SavingGoalResponse>> GetAllUserGoalsAsync(int userId, PageDTO pageDto);

        // Add a new savings goal
        public Task<int> AddGoalAsync(int userID,SavingGoalDTO goalDto);

        // Update an existing goal
        public Task<bool> UpdateGoalAsync(int goalId, SavingGoalDTO goalDto);

        // Delete a goal
        public Task<bool> DeleteGoalAsync(int goalId);

        // Check if a goal exists
        public Task<bool> GoalExistsAsync(int goalId);
        public Task<IEnumerable<SavingGoalResponse>> GetAchievedGoalsAsync(int userId);
        public Task<bool>AddAmountToSavingGoal(int savingGoalId,int walletId,int userId, double amount);
        public Task <bool>WithdrawAmountFromSavingGoal(int savingGoalId,int walletId, int userId , double amount) ;
    }
}
