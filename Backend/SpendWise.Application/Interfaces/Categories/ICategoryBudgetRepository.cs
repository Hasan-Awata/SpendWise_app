using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Categories
{
    public interface ICategoryBudgetRepository
    {
        public Task<IEnumerable<CategoryBudget>> GetAllUserBudgetsAsync(int userId);
        public Task<CategoryBudget> GetCategoryBudgetAsync(int userId, int categoryId);

        public Task<int> SetCategoryBudgetAsync(int userId, CategoryBudget categoryBudger);
        public Task<bool> UpdateCategoryBudgetAsync(CategoryBudget categoryBudget);
        public Task<bool> DeleteCategoryBudgetAsync(int userId, int categoryId);
    }
}
