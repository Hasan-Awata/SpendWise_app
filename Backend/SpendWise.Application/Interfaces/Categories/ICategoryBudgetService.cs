using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Categories
{
    public interface ICategoryBudgetService
    {
        public Task<IEnumerable<CategoryBudgetResponse>> GetAllUserBudgetsAsync(int userId);

        public Task<CategoryBudgetResponse?> GetCategoryBudgetAsync(int userId, int categoryId);

        public Task<int> SetCategoryBudgetAsync(CategoryBudgetDTO budgetDto);

        public Task<bool> UpdateCategoryBudgetAsync(CategoryBudgetDTO budgetDto);

        public Task<bool> DeleteCategoryBudgetAsync(int userId, int categoryId);
    }
}
