using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Domain.Entities;
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
                                            ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }
        public async Task<int> AddGoalAsync(SavingGoal goal)
        {
            int GoalID = -1;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_CreateSavingsGoal]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewGoalID", goal.GoalID);
                    command.Parameters.AddWithValue("@UserID", goal.UserID);
                    command.Parameters.AddWithValue("@Title", goal.Title);
                    command.Parameters.AddWithValue("@TargetAmount", goal.TargetAmount);
                    command.Parameters.AddWithValue("@CurrentAmount", goal.CurrentAmount);
                    command.Parameters.AddWithValue("@DeadlineDate", goal.DeadlineDate);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int insertedID))
                        {
                            GoalID = insertedID;
                            goal.GoalID = GoalID;
                        }
                    }
                    catch (Exception)
                    {
                        return GoalID;
                    }
                }
                return GoalID;
            }
        }

        public async Task<bool> UpdateGoalAsync(SavingGoal updatedGoal)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_UpdateSavingsGoal]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@GoalID", updatedGoal.GoalID);
                    command.Parameters.AddWithValue("@UserID", updatedGoal.UserID);
                    command.Parameters.AddWithValue("@Title", updatedGoal.Title);
                    command.Parameters.AddWithValue("@TargetAmount", updatedGoal.TargetAmount);
                    command.Parameters.AddWithValue("@CurrentAmount", updatedGoal.CurrentAmount);
                    command.Parameters.AddWithValue("@DeadlineDate", updatedGoal.DeadlineDate);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }

        public async Task<bool> DeleteGoalAsync(int goalId)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_DeleteSavingsGoal]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@GoalID", goalId);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }

        public async Task<SavingGoal?> GetGoalByIdAsync(int goalId)
        {
            SavingGoal? goal = null;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetSavingsGoalByID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@GoalID", goalId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                goal = new SavingGoal(
                                    (int)reader["GoalID"],
                                    (int)reader["UserID"],
                                    (string)reader["Title"],
                                    (decimal)reader["TargetAmount"],
                                    (decimal)reader["CurrentAmount"],
                                    (DateTime)reader["DeadlineDate"]
                                );
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return goal;
        }

        public async Task<IEnumerable<SavingGoal>> GetAllUserGoalsAsync(int userId)
        {
            List<SavingGoal> goals = new List<SavingGoal>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetAllUserGoals]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", userId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                SavingGoal goal = new SavingGoal(
                                    (int)reader["GoalID"],
                                    (int)reader["UserID"],
                                    (string)reader["Title"],
                                    (decimal)reader["TargetAmount"],
                                    (decimal)reader["CurrentAmount"],
                                    (DateTime)reader["DeadlineDate"]
                                );
                                goals.Add(goal);
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }

            return goals;
        }

        public async Task<IEnumerable<SavingGoal>> GetAchievedGoalsAsync(int userId)
        {
            List<SavingGoal> goals = new List<SavingGoal>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetAchievedGoals]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", userId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                SavingGoal goal = new SavingGoal(
                                    (int)reader["GoalID"],
                                    (int)reader["UserID"],
                                    (string)reader["Title"],
                                    (decimal)reader["TargetAmount"],
                                    (decimal)reader["CurrentAmount"],
                                    (DateTime)reader["DeadlineDate"]
                                );
                                goals.Add(goal);
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }

            return goals;
        }

        public async Task<bool> GoalExistsAsync(int goalId)
        {
            bool exists = false;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_IsGoalExist]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@GoalID", goalId);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int count))
                        {
                            exists = (count > 0);
                        }
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return exists;
        }
    }
}