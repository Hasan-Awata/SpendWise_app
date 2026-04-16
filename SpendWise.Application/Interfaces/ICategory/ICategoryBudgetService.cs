using SpendWise.Application.DTOs.Category;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.CategoryBudget
{
    public interface ICategoryBudgetService
    {

       public Task<IEnumerable<CategoryBudgetResponse>> GetAllUserBudgetsAsync(int userId);

        // Retrieves a specific category budget by its ID
        public Task<CategoryBudgetResponse?> GetCategoryBudgetByIdAsync(int categoryBudgetId);

        // Adds a new category budget for the user
        public Task<int> AddCategoryBudgetAsync(int userId, CategoryBudgetDTO budgetDto);

        // Updates an existing category budget
        public Task<bool> UpdateCategoryBudgetAsync(int categoryBudgetId, CategoryBudgetDTO budgetDto);

        // Deletes a category budget
        public Task<bool> DeleteCategoryBudgetAsync(int categoryBudgetId);

        // Checks if a category budget exists
        public Task<bool> CategoryBudgetExistsAsync(int categoryBudgetId);
    }
}
