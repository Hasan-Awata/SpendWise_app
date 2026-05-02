using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.Categories;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class CategoryBudgetService : ICategoryBudgetService
    {
        private readonly ICategoryBudgetRepository _budgetRepo;

        public CategoryBudgetService(ICategoryBudgetRepository budgetRepo)
        {
            _budgetRepo = budgetRepo;
        }

       
        public async Task<IEnumerable<CategoryBudgetResponse>> GetAllUserBudgetsAsync(int userId)
        {
            var budgets = await _budgetRepo.GetAllUserBudgetsAsync(userId);

            if (budgets == null) return Enumerable.Empty<CategoryBudgetResponse>();

            return budgets.Select(budget => new CategoryBudgetResponse
            {
                CategoryBudgetId = budget.CategoryBudgetId,
                CategoryId = budget.CategoryId,
                UserId = budget.UserId,
                PercentageLimit = budget.PercentageLimit,
                PercentageProgress = budget.PercentageProgress,
                IsActive = budget.IsActive,
                StartDate = budget.StartDate,
                EndDate = budget.EndDate,
            });
          
        }

       
        public async Task<CategoryBudgetResponse?> GetCategoryBudgetAsync(int userId, int categoryId)
        {
            var budget = await _budgetRepo.GetCategoryBudgetAsync(userId, categoryId);

            return budget != null ? new CategoryBudgetResponse
            {
                CategoryBudgetId = budget.CategoryBudgetId,
                CategoryId = budget.CategoryId,
                UserId = budget.UserId,
                PercentageLimit = budget.PercentageLimit,
                PercentageProgress = budget.PercentageProgress,
                IsActive = budget.IsActive,
                StartDate = budget.StartDate,
                EndDate = budget.EndDate,
            }: null;
        }

        public async Task<int> SetCategoryBudgetAsync(CategoryBudgetDTO budgetDto)
        {
            
            var budget = new CategoryBudget(-1, budgetDto.UserId, budgetDto.CategoryId, budgetDto.PercentageLimit, budgetDto.PercentageProgress, budgetDto.StartDate, budgetDto.EndDate, budgetDto.IsActive);

            return await _budgetRepo.SetCategoryBudgetAsync(budgetDto.UserId, budget);
        }

        public async Task<bool> UpdateCategoryBudgetAsync(CategoryBudgetDTO budgetDto)
        {
            var budget = new CategoryBudget(-1, budgetDto.UserId, budgetDto.CategoryId, budgetDto.PercentageLimit, budgetDto.PercentageProgress, budgetDto.StartDate, budgetDto.EndDate, budgetDto.IsActive);

            return await _budgetRepo.UpdateCategoryBudgetAsync(budget);
        }


        public async Task<bool> DeleteCategoryBudgetAsync(int userId, int categoryId)
        {
            return await _budgetRepo.DeleteCategoryBudgetAsync(userId, categoryId);
        }
    }
}
