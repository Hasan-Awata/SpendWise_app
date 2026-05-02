using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Categorys;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace SpendWise.Infrastructure.Repositories
{
    public class CategoryBudgetRepository :ICategoryBudgetRepository
    {
        private readonly string _connectionString;

        public CategoryBudgetRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<IEnumerable<CategoryBudget>> GetAllUserBudgetsAsync(int userId)
        {
            List<CategoryBudget> budgets = new List<CategoryBudget>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetAllUserBudgets]", connection))
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
                                // Adjust these mappings based on your actual Category entity properties
                                budgets.Add(new CategoryBudget(
                                    (int)reader["CategoryBudgetId"],
                                    (int)reader["UserID"],
                                    (int)reader["CategoryID"],
                                    (decimal)reader["PercentageLimit"],
                                    (decimal)reader["PercentageProgress"],
                                    (DateTime)reader["StartDate"],
                                    (DateTime)reader["EndDate"],
                                    (bool)reader["IsActive"]
                                ));
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return budgets;
        }

        public async Task<CategoryBudget?> GetCategoryBudgetByIdAsync(int categoryBudgetId)
        {
            CategoryBudget? budget = null;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetCategoryBudgetByID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CategoryBudgetId", categoryBudgetId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                budget = new CategoryBudget(
                                    (int)reader["CategoryBudgetId"],
                                    (int)reader["UserID"],
                                    (int)reader["CategoryID"],
                                    (decimal)reader["PercentageLimit"],
                                    (decimal)reader["PercentageProgress"],
                                    (DateTime)reader["StartDate"],
                                    (DateTime)reader["EndDate"],
                                    (bool)reader["IsActive"]
                                );
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return budget;
        }

        public async Task<int> AddCategoryBudgetAsync(int userId, CategoryBudget budget)
        {
            int newId = -1;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_CreateCategoryBudget]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", userId);
                    command.Parameters.AddWithValue("@CategoryID", budget.CategoryId);
                    command.Parameters.AddWithValue("@PercentageLimit", budget.PercentageLimit);
                    command.Parameters.AddWithValue("@PercentageProgress", budget.PercentageProgress);
                    command.Parameters.AddWithValue("@StartDate", budget.StartDate);
                    command.Parameters.AddWithValue("@EndDate", budget.EndDate);
                    command.Parameters.AddWithValue("@IsActive", budget.IsActive);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null) newId = Convert.ToInt32(result);
                    }
                    catch (Exception) { return -1; }
                }
            }
            return newId;
        }

        public async Task<bool> UpdateCategoryBudgetAsync(int categoryBudgetId, CategoryBudget budget)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_UpdateCategoryBudget]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CategoryBudgetId", categoryBudgetId);
                    command.Parameters.AddWithValue("@CategoryID", budget.CategoryId);
                    command.Parameters.AddWithValue("@PercentageLimit", budget.PercentageLimit);
                    command.Parameters.AddWithValue("@PercentageProgress", budget.PercentageProgress);
                    command.Parameters.AddWithValue("@StartDate", budget.StartDate);
                    command.Parameters.AddWithValue("@EndDate", budget.EndDate);
                    command.Parameters.AddWithValue("@IsActive", budget.IsActive);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception) { return false; }
                }
            }
            return rowsAffected > 0;
        }

        public async Task<bool> DeleteCategoryBudgetAsync(int categoryBudgetId)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_DeleteCategoryBudget]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CategoryBudgetId", categoryBudgetId);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception) { return false; }
                }
            }
            return rowsAffected > 0;
        }

        public async Task<bool> CategoryBudgetExistsAsync(int categoryBudgetId)
        {
            bool exists = false;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_IsCategoryBudgetExist]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CategoryBudgetId", categoryBudgetId);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null) exists = (Convert.ToInt32(result) > 0);
                    }
                    catch (Exception) { return false; }
                }
            }
            return exists;
        }
    }
}
