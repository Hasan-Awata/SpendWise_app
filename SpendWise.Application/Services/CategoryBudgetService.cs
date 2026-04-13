using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.CategoryBudget;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public   class CategoryBudgetService :ICategoryBudgetService
    {
        //private readonly ICategoryBudgetRepository _budgetRepo;

        //public CategoryBudgetService(ICategoryBudgetRepository budgetRepo)
        //{
        //    _budgetRepo = budgetRepo;
        //}

        // Retrieves all category budgets for a specific user and maps them to responses
        public async Task<IEnumerable<CategoryBudgetResponse>> GetAllUserBudgetsAsync(int userId)
        {
            //var budgets = await _budgetRepo.GetAllUserBudgetsAsync(userId);

            //if (budgets == null) return Enumerable.Empty<CategoryBudgetResponse>();

            //// Using the constructor in CategoryBudgetResponse for cleaner mapping
            //return budgets.Select(budget => new CategoryBudgetResponse(budget));
            return null;
        }

        // Retrieves a specific category budget by its ID
        public async Task<CategoryBudgetResponse?> GetCategoryBudgetByIdAsync(int categoryBudgetId)
        {
            //var budget = await _budgetRepo.GetByIdAsync(categoryBudgetId);

            //  return budget != null ? new CategoryBudgetResponse(budget) : null;
            return null;

        }

        // Adds a new category budget and returns the new ID
        public async Task<int> AddCategoryBudgetAsync(int userId, CategoryBudgetDTO budgetDto)
        {
            // Logic to convert DTO to Entity before saving
            var budget = new CategoryBudget
            {
                UserId = userId,
                Category = new Category(budgetDto.Category.CategoryId,budgetDto.Category.Name,budgetDto.Category.Priority),
                PercentageLimit = budgetDto.PercentageLimit,
                PercentageProgress = budgetDto.PercentageProgress,
                StartDate = budgetDto.StartDate,
                EndDate = budgetDto.EndDate,
                IsActive = budgetDto.IsActive
            };

            // return await _budgetRepo.AddAsync(budget);
            return -1;

        }

        // Updates an existing category budget
        public async Task<bool> UpdateCategoryBudgetAsync(int categoryBudgetId, CategoryBudgetDTO budgetDto)
        {
           // var existingBudget = await _budgetRepo.GetByIdAsync(categoryBudgetId);
            //if (existingBudget == null) return false;

            //// Map DTO updates to the existing entity
            //existingBudget.PercentageLimit = budgetDto.PercentageLimit;
            //existingBudget.PercentageProgress = budgetDto.PercentageProgress;
            //existingBudget.StartDate = budgetDto.StartDate;
            //existingBudget.EndDate = budgetDto.EndDate;
            //existingBudget.IsActive = budgetDto.IsActive;

            //return await _budgetRepo.UpdateAsync(existingBudget);
            return false;
        }

        // Deletes a category budget
        public async Task<bool> DeleteCategoryBudgetAsync(int categoryBudgetId)
        {
            // return await _budgetRepo.DeleteAsync(categoryBudgetId);
            return false;
        }

        // Checks if a category budget exists
        public async Task<bool> CategoryBudgetExistsAsync(int categoryBudgetId)
        {
            //return await _budgetRepo.ExistsAsync(categoryBudgetId);
            return false;

        }
    }
}
