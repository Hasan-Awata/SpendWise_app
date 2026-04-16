using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.CategoryBudget;
using SpendWise.Application.Interfaces.Categorys;
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

            // Using the constructor in CategoryBudgetResponse for cleaner mapping
            return budgets.Select(budget => new CategoryBudgetResponse(budget));
          
        }

       
        public async Task<CategoryBudgetResponse?> GetCategoryBudgetByIdAsync(int categoryBudgetId)
        {
            var budget = await _budgetRepo.GetCategoryBudgetByIdAsync(categoryBudgetId);

            return budget != null ? new CategoryBudgetResponse(budget) : null;
            

        }

        public async Task<int> AddCategoryBudgetAsync(int userId, CategoryBudgetDTO budgetDto)
        {

            var budget = new CategoryBudget(-1, userId, budgetDto.CategoryDto.CategoryId, budgetDto.PercentageLimit, budgetDto.PercentageProgress, budgetDto.StartDate, budgetDto.EndDate, budgetDto.IsActive);

           

            return await _budgetRepo.AddCategoryBudgetAsync(userId,budget);
           

        }

        public async Task<bool> UpdateCategoryBudgetAsync(int categoryBudgetId, CategoryBudgetDTO budgetDto)
        {
            var existingBudget = await _budgetRepo.GetCategoryBudgetByIdAsync(categoryBudgetId);
            if (existingBudget == null) return false;

            // Map DTO updates to the existing entity
            existingBudget.PercentageLimit = budgetDto.PercentageLimit;
            existingBudget.PercentageProgress = budgetDto.PercentageProgress;
            existingBudget.StartDate = budgetDto.StartDate;
            existingBudget.EndDate = budgetDto.EndDate;
            existingBudget.IsActive = budgetDto.IsActive;

            return await _budgetRepo.UpdateCategoryBudgetAsync(categoryBudgetId,existingBudget);
           
        }

       
        public async Task<bool> DeleteCategoryBudgetAsync(int categoryBudgetId)
        {
            return await _budgetRepo.DeleteCategoryBudgetAsync(categoryBudgetId);
           
        }

        
        public async Task<bool> CategoryBudgetExistsAsync(int categoryBudgetId)
        {
            return await _budgetRepo.CategoryBudgetExistsAsync(categoryBudgetId);
            

        }
    }
}
