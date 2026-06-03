using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Domain.Common;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.SavingGoals
{
    public interface ISavingGoalService
    {
        // Get a specific goal by its ID
        public Task<Result<SavingGoalResponse>> GetGoalByIdAsync(int goalId);

        // Get all goals for a specific user
        public Task<Result<PagedResponse<SavingGoalResponse>>> GetAllUserGoalsAsync(int userId, PageDTO pageDto);

        // Add a new savings goal
        public Task<Result<int>> AddGoalAsync(int userID,SavingGoalDTO goalDto);

        // Update an existing goal
        public Task<Result> UpdateGoalAsync(int goalId, SavingGoalDTO goalDto);

        // Delete a goal
        public Task<Result> DeleteGoalAsync(int goalId);

        // Check if a goal exists
        public Task<Result<bool>> GoalExistsAsync(int goalId);
        public Task<Result<IEnumerable<SavingGoalResponse>>> GetAchievedGoalsAsync(int userId);
        public Task<Result<bool>> AddAmountToSavingGoal(int savingGoalId,int walletId,int userId, double amount);
        public Task<Result<bool>> WithdrawAmountFromSavingGoal(int savingGoalId,int walletId, int userId , double amount) ;
    }
}
