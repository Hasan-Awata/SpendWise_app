using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Categorys
{
    public interface ICategoryBudgetRepository
    {
        public Task<IEnumerable<Domain.Entities.CategoryBudget>> GetAllUserBudgetsAsync(int userId);

        // Retrieves a specific category budget by its ID
        public Task<Domain.Entities.CategoryBudget?> GetCategoryBudgetByIdAsync(int categoryBudgetId);

        // Adds a new category budget for the user
        public Task<int> AddCategoryBudgetAsync(int userId, Domain.Entities.CategoryBudget budgetDto);

        // Updates an existing category budget
        public Task<bool> UpdateCategoryBudgetAsync(int categoryBudgetId, Domain.Entities.CategoryBudget budgetDto);

        // Deletes a category budget
        public Task<bool> DeleteCategoryBudgetAsync(int categoryBudgetId);

        // Checks if a category budget exists
        public Task<bool> CategoryBudgetExistsAsync(int categoryBudgetId);

    }
}
