using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class SavingGoalRepository : BaseRepository, ISavingGoalRepository
    {
        public SavingGoalRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<bool> AddAmountToSavingGoalTransactionAsync(int goalId, int walletId, int userId, decimal amountFromWallet, decimal amountToSavingGoal, decimal amountInSp)
        {
            try
            {
                var result = await ExecuteScalarAsync<int>("[Planning].[sp_AddAmountToSavingGoalWithTransaction]", cmd =>
                {
                    cmd.Parameters.AddWithValue("@GoalId", goalId);
                    cmd.Parameters.AddWithValue("@WalletId", walletId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@AmountFromWallet", amountFromWallet);
                    cmd.Parameters.AddWithValue("@AmountToSavingGoal", amountToSavingGoal);
                    cmd.Parameters.AddWithValue("@AmountInSp", amountInSp);
                    cmd.Parameters.AddWithValue("@TransactionTitle", "Transfer money to the savings goal");
                    cmd.Parameters.AddWithValue("@TransactionType", 1);
                });

                return result == 1;
            }
            catch (SqlException)
            {
                // Maintained original behavior to suppress specific exceptions and return false
                return false;
            }
        }

        public async Task<int> AddGoalAsync(SavingGoal goal)
        {
            SqlParameter? outputId = null;

            await ExecuteScalarAsync<object>("[Planning].[sp_AddSavingGoal]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", goal.UserID);
                cmd.Parameters.AddWithValue("@Title", goal.Title);
                cmd.Parameters.AddWithValue("@TargetAmount", goal.TargetAmount);
                cmd.Parameters.AddWithValue("@CurrentAmount", goal.CurrentAmount);
                cmd.Parameters.AddWithValue("@DeadlineDate", (object?)goal.DeadlineDate ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@CurrencyId", goal.CurrencyId);
                cmd.Parameters.AddWithValue("@IsAchieved", false);

                // Output parameter configuration via closure
                outputId = new SqlParameter("@NewGoalID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outputId);
            });

            return (int)(outputId?.Value ?? -1);
        }

        public async Task<bool> UpdateGoalAsync(SavingGoal updatedGoal)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_UpdateSavingGoal]", cmd =>
            {
                cmd.Parameters.AddWithValue("@GoalId", updatedGoal.GoalID);
                cmd.Parameters.AddWithValue("@UserId", updatedGoal.UserID);
                cmd.Parameters.AddWithValue("@Title", updatedGoal.Title);
                cmd.Parameters.AddWithValue("@TargetAmount", updatedGoal.TargetAmount);
                cmd.Parameters.AddWithValue("@CurrentAmount", updatedGoal.CurrentAmount);
                cmd.Parameters.AddWithValue("@DeadlineDate", updatedGoal.DeadlineDate);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteGoalAsync(int goalId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_DeleteSavingGoal]", cmd =>
            {
                cmd.Parameters.AddWithValue("@GoalId", goalId);
            });

            return rowsAffected > 0;
        }

        public async Task<SavingGoal?> GetGoalByIdAsync(int goalId)
        {
            return await ExecuteReaderSingleAsync("[Planning].[sp_GetSavingGoalById]",
                cmd => cmd.Parameters.AddWithValue("@GoalID", goalId), MapToSavingGoal);
        }

        public async Task<(IEnumerable<SavingGoal> goals, int totalCount)> GetAllUserGoalsAsync(int userId, int pageNumber, int pageSize)
        {
            var goals = new List<SavingGoal>();
            int totalCount = 0;

            // Sequential processing for multiple result sets via Grid Reader delegate pattern
            await ExecuteReaderAsync("[Planning].[sp_GetAllUserGoalsPaged]",
                cmd =>
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@PageNumber", pageNumber);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);
                },
                async reader =>
                {
                    // Result Set 1: Total Row Count
                    if (await reader.ReadAsync())
                    {
                        totalCount = EmptyValuesHandler.GetInt32OrDefault(reader, "TotalCount");
                    }

                    // Result Set 2: Paged Goals List
                    if (await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            goals.Add(MapToSavingGoal(reader));
                        }
                    }
                    return default(object); // Dummy return to satisfy core functional signatures
                });

            return (goals, totalCount);
        }

        public async Task<IEnumerable<SavingGoal>> GetAchievedGoalsAsync(int userId)
        {
            return await ExecuteReaderAsync("[Planning].[sp_GetAchievedGoals]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapToSavingGoal);
        }

        public async Task<bool> GoalExistsAsync(int goalId)
        {
            var result = await ExecuteScalarAsync<int>("[Planning].[sp_CheckSavingGoalExists]",
                cmd => cmd.Parameters.AddWithValue("@GoalId", goalId));

            return result > 0;
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static SavingGoal MapToSavingGoal(SqlDataReader reader)
        {
            return new SavingGoal(
                EmptyValuesHandler.GetInt32OrDefault(reader, "GoalID"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "TargetAmount"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "CurrentAmount"),
                EmptyValuesHandler.GetDateTimeOrDefault(reader, "DeadlineDate"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "CurrencyID"),
                EmptyValuesHandler.GetBooleanOrDefault(reader, "IsAchieved")
            );
        }
    }
}