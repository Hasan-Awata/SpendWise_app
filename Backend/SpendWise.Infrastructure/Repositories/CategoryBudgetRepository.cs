using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.Categories;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class CategoryBudgetRepository : ICategoryBudgetRepository
    {
        private readonly string _connectionString;

        public CategoryBudgetRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<int> SetCategoryBudgetAsync(int userId, CategoryBudget categoryBudget)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_AddCategoryBudget]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserID", userId);
                command.Parameters.AddWithValue("@CategoryID", categoryBudget.CategoryId);
                command.Parameters.AddWithValue("@PercentageLimit", categoryBudget.PercentageLimit);
                command.Parameters.AddWithValue("@StartDate", categoryBudget.StartDate);
                command.Parameters.AddWithValue("@EndDate", categoryBudget.EndDate);
                command.Parameters.AddWithValue("@IsActive", categoryBudget.IsActive);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int insertedID) ? insertedID : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> UpdateCategoryBudgetAsync(CategoryBudget categoryBudget)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_UpdateCategoryBudget]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@BudgetID", categoryBudget.CategoryBudgetId);
                command.Parameters.AddWithValue("@UserID", categoryBudget.UserId);
                command.Parameters.AddWithValue("@CategoryID", categoryBudget.CategoryId);
                command.Parameters.AddWithValue("@PercentageLimit", categoryBudget.PercentageLimit);
                command.Parameters.AddWithValue("@StartDate", categoryBudget.StartDate);
                command.Parameters.AddWithValue("@EndDate", categoryBudget.EndDate);
                command.Parameters.AddWithValue("@IsActive", categoryBudget.IsActive);

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

        public async Task<bool> DeleteCategoryBudgetAsync(int userId, int categoryId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_DeleteCategoryBudget]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserID", userId);
                command.Parameters.AddWithValue("@CategoryID", categoryId);

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

        public async Task<IEnumerable<CategoryBudget>> GetAllUserBudgetsAsync(int userId)
        {
            var budgets = new List<CategoryBudget>();
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_GetAllUserBudgets]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };
                command.Parameters.AddWithValue("@UserID", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    budgets.Add(new CategoryBudget
                    {
                        CategoryBudgetId = (int)reader["BudgetID"],
                        UserId = (int)reader["UserID"],
                        CategoryId = (int)reader["CategoryID"],
                        PercentageLimit = (decimal)reader["PercentageLimit"],
                        PercentageProgress = (decimal)reader["PercentageProgress"],
                        StartDate = (DateTime)reader["StartDate"],
                        EndDate = (DateTime)reader["EndDate"],
                        IsActive = (bool)reader["IsActive"]
                    });
                }
            }
            catch (SqlException ex) { SqlExceptionHandler.Handle(ex); throw; }
            return budgets;
        }

        public async Task<CategoryBudget> GetCategoryBudgetAsync(int userId, int categoryId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);

                using var command = new SqlCommand("[Planning].[sp_GetCategoryBudget]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@CategoryID", categoryId);
                command.Parameters.AddWithValue("@UserID", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new CategoryBudget
                    {
                        CategoryBudgetId = (int)reader["BudgetID"],
                        UserId = (int)reader["UserID"],
                        CategoryId = (int)reader["CategoryID"],
                        PercentageLimit = (decimal)reader["PercentageLimit"], 
                        PercentageProgress = (decimal)reader["PercentageProgress"],
                        MoneyLimit = (decimal)reader["MoneyLimit"], 
                        SpendingProgress = (decimal)reader["SpendingProgress"],             
                        StartDate = (DateTime)reader["StartDate"],
                        EndDate = (DateTime)reader["EndDate"],
                        IsActive = (bool)reader["IsActive"]
                    };
                }
                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}