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
    public class CategoryBudgetRepository : BaseRepository, ICategoryBudgetRepository
    {
        public CategoryBudgetRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings.")) { }

        public async Task<int> SetCategoryBudgetAsync(int userId, CategoryBudget categoryBudget)
        {
            var result = await ExecuteNonQueryAsync("[Planning].[sp_AddCategoryBudget]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CategoryID", categoryBudget.CategoryId);
                cmd.Parameters.AddWithValue("@PercentageLimit", categoryBudget.PercentageLimit);
                cmd.Parameters.AddWithValue("@StartDate", categoryBudget.StartDate);
                cmd.Parameters.AddWithValue("@EndDate", categoryBudget.EndDate);
                cmd.Parameters.AddWithValue("@IsActive", categoryBudget.IsActive);
            });

            return result > 0 ? result : -1;
        }

        public async Task<bool> UpdateCategoryBudgetAsync(CategoryBudget categoryBudget)
        {
            var rowsAffected = await ExecuteNonQueryAsync("[Planning].[sp_UpdateCategoryBudget]", cmd =>
            {
                cmd.Parameters.AddWithValue("@BudgetID", categoryBudget.CategoryBudgetId);
                cmd.Parameters.AddWithValue("@UserID", categoryBudget.UserId);
                cmd.Parameters.AddWithValue("@CategoryID", categoryBudget.CategoryId);
                cmd.Parameters.AddWithValue("@PercentageLimit", categoryBudget.PercentageLimit);
                cmd.Parameters.AddWithValue("@StartDate", categoryBudget.StartDate);
                cmd.Parameters.AddWithValue("@EndDate", categoryBudget.EndDate);
                cmd.Parameters.AddWithValue("@IsActive", categoryBudget.IsActive);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteCategoryBudgetAsync(int userId, int categoryId)
        {
            var rowsAffected = await ExecuteNonQueryAsync("[Planning].[sp_DeleteCategoryBudget]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CategoryID", categoryId);
            });

            return rowsAffected > 0;
        }

        public async Task<IEnumerable<CategoryBudget>> GetAllUserBudgetsAsync(int userId)
        {
            return await ExecuteReaderAsync("[Planning].[sp_GetAllUserBudgets]",
                cmd => cmd.Parameters.AddWithValue("@UserID", userId), MapReaderToCategoryBudget);
        }

        public async Task<CategoryBudget?> GetCategoryBudgetAsync(int userId, int categoryId)
        {
            return await ExecuteReaderSingleAsync("[Planning].[sp_GetCategoryBudget]", cmd =>
            {
                cmd.Parameters.AddWithValue("@CategoryID", categoryId);
                cmd.Parameters.AddWithValue("@UserID", userId);
            }, MapReaderToCategoryBudget);
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static CategoryBudget MapReaderToCategoryBudget(SqlDataReader reader)
        {
            return new CategoryBudget
            {
                CategoryBudgetId = EmptyValuesHandler.GetInt32OrDefault(reader, "BudgetID"),
                UserId = EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                CategoryId = EmptyValuesHandler.GetInt32OrDefault(reader, "CategoryID"),

                // Calculated metrics / limits cleanly handled via your global handler
                PercentageLimit = EmptyValuesHandler.GetDecimalOrDefault(reader, "PercentageLimit"),
                PercentageProgress = EmptyValuesHandler.GetDecimalOrDefault(reader, "PercentageProgress"),
                SpendingProgress = EmptyValuesHandler.GetDecimalOrDefault(reader, "SpendingProgress"),
                MoneyLimit = EmptyValuesHandler.GetDecimalOrDefault(reader, "MoneyLimit"),

                StartDate = EmptyValuesHandler.GetDateTimeOrDefault(reader, "StartDate"),
                EndDate = EmptyValuesHandler.GetDateTimeOrDefault(reader, "EndDate"),
                IsActive = EmptyValuesHandler.GetBooleanOrDefault(reader, "IsActive")
            };
        }
    }
}