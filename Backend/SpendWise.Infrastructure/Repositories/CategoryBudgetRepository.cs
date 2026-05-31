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

                // Safely handle potential DBNull or null returns from scalar execution
                return result != null && result != DBNull.Value && int.TryParse(result.ToString(), out int insertedID) ? insertedID : -1;
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

                return result != null && result != DBNull.Value && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
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

                return result != null && result != DBNull.Value && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
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
                    budgets.Add(MapReaderToCategoryBudget(reader));
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
                    return MapReaderToCategoryBudget(reader);
                }
                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        /// <summary>
        /// Helper method to cleanly map a SqlDataReader to a CategoryBudget object while checking for DBNull values.
        /// </summary>
        private static CategoryBudget MapReaderToCategoryBudget(SqlDataReader reader)
        {
            return new CategoryBudget
            {
                CategoryBudgetId = reader["BudgetID"] != DBNull.Value ? (int)reader["BudgetID"] : 0,
                UserId = reader["UserID"] != DBNull.Value ? (int)reader["UserID"] : 0,
                CategoryId = reader["CategoryID"] != DBNull.Value ? (int)reader["CategoryID"] : 0,

                // Calculated metrics / limits often prone to being null if no transactions exist yet
                PercentageLimit = reader["PercentageLimit"] != DBNull.Value ? (decimal)reader["PercentageLimit"] : 0m,
                PercentageProgress = reader["PercentageProgress"] != DBNull.Value ? (decimal)reader["PercentageProgress"] : 0m,
                SpendingProgress = reader["SpendingProgress"] != DBNull.Value ? (decimal)reader["SpendingProgress"] : 0m,
                MoneyLimit = reader["MoneyLimit"] != DBNull.Value ? (decimal)reader["MoneyLimit"] : 0m,

                StartDate = reader["StartDate"] != DBNull.Value ? (DateTime)reader["StartDate"] : DateTime.MinValue,
                EndDate = reader["EndDate"] != DBNull.Value ? (DateTime)reader["EndDate"] : DateTime.MinValue,
                IsActive = reader["IsActive"] != DBNull.Value && (bool)reader["IsActive"]
            };
        }
    }
}