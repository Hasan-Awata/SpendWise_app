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
    public class SavingGoalRepository : ISavingGoalRepository
    {
        private readonly string _connectionString;

        public SavingGoalRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings.");
        }

        public async Task<int> AddGoalAsync(SavingGoal goal)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_AddSavingGoal]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", goal.UserID);
                command.Parameters.AddWithValue("@Title", goal.Title);
                command.Parameters.AddWithValue("@TargetAmount", goal.TargetAmount);
                command.Parameters.AddWithValue("@CurrentAmount", goal.CurrentAmount);
                command.Parameters.AddWithValue("@DeadlineDate", goal.DeadlineDate);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int insertedId) ? insertedId : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> UpdateGoalAsync(SavingGoal updatedGoal)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_UpdateSavingGoal]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@GoalId", updatedGoal.GoalID);
                command.Parameters.AddWithValue("@UserId", updatedGoal.UserID);
                command.Parameters.AddWithValue("@Title", updatedGoal.Title);
                command.Parameters.AddWithValue("@TargetAmount", updatedGoal.TargetAmount);
                command.Parameters.AddWithValue("@CurrentAmount", updatedGoal.CurrentAmount);
                command.Parameters.AddWithValue("@DeadlineDate", updatedGoal.DeadlineDate);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> DeleteGoalAsync(int goalId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_DeleteSavingGoal]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@GoalId", goalId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<SavingGoal?> GetGoalByIdAsync(int goalId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_GetSavingGoalById]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@GoalId", goalId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new SavingGoal(
                        Convert.ToInt32(reader["GoalID"]),
                        Convert.ToInt32(reader["UserID"]),
                        reader["Title"].ToString()!,
                        Convert.ToDecimal(reader["TargetAmount"]),
                        Convert.ToDecimal(reader["CurrentAmount"]),
                        Convert.ToDateTime(reader["DeadlineDate"]),
                        Convert.ToInt32(reader["CurrencyID"])
                    );
                }

                return null;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<(IEnumerable<SavingGoal> goals, int totalCount)> GetAllUserGoalsAsync(int userId, int pageNumber, int pageSize)
        {
            var goals = new List<SavingGoal>();
            int totalCount = 0;

            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_GetAllUserGoalsPaged]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@PageNumber", pageNumber);
                command.Parameters.AddWithValue("@PageSize", pageSize);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                // First Result Set: Total Count
                if (await reader.ReadAsync())
                {
                    totalCount = Convert.ToInt32(reader["TotalCount"]);
                }

                // Second Result Set: The Goals
                if (await reader.NextResultAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        goals.Add(new SavingGoal(
                            Convert.ToInt32(reader["GoalID"]),
                            Convert.ToInt32(reader["UserID"]),
                            reader["Title"].ToString()!,
                            Convert.ToDecimal(reader["TargetAmount"]),
                            Convert.ToDecimal(reader["CurrentAmount"]),
                            Convert.ToDateTime(reader["DeadlineDate"]),
                            Convert.ToInt32(reader["CurrencyID"])
                        ));
                    }
                }

                return (goals, totalCount);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<SavingGoal>> GetAchievedGoalsAsync(int userId)
        {
            var goals = new List<SavingGoal>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_GetAchievedGoals]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    goals.Add(new SavingGoal(
                        Convert.ToInt32(reader["GoalID"]),
                        Convert.ToInt32(reader["UserID"]),
                        reader["Title"].ToString()!,
                        Convert.ToDecimal(reader["TargetAmount"]),
                        Convert.ToDecimal(reader["CurrentAmount"]),
                        Convert.ToDateTime(reader["DeadlineDate"]),
                        Convert.ToInt32(reader["CurrencyID"])
                    ));
                }

                return goals;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> GoalExistsAsync(int goalId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                // Updated schema from [Ledger] to [Planning]
                using var command = new SqlCommand("[Planning].[sp_CheckSavingGoalExists]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@GoalId", goalId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && Convert.ToInt32(result) > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}