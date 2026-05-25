using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.Categories;
using SpendWise.Domain.Common;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;

namespace SpendWise.Application.Services
{
    public class CategoryBudgetService : ICategoryBudgetService
    {
        private readonly ICategoryBudgetRepository _budgetRepo;

        public CategoryBudgetService(ICategoryBudgetRepository budgetRepo)
        {
            _budgetRepo = budgetRepo;
        }

        // Helpers methods --------------------------------------------------
        private CategoryBudget MapBudgetDTOtoBudgetObject(CategoryBudgetDTO budgetDto)
        {
            return new CategoryBudget
            (
                budgetDto.CategoryBudgetId,
                budgetDto.UserId,
                budgetDto.CategoryId,
                budgetDto.PercentageLimit,
                budgetDto.PercentageProgress,
                budgetDto.StartDate,
                budgetDto.EndDate,
                budgetDto.IsActive
            );
        }

        private CategoryBudgetResponse MapBudgetToBudgetResponse(CategoryBudget budget)
        {
            return new CategoryBudgetResponse(budget);
        }

        // Reading methods --------------------------------------------------
        public async Task<Result<IEnumerable<CategoryBudgetResponse>>> GetAllUserBudgetsAsync(int userId)
        {
            var budgets = await _budgetRepo.GetAllUserBudgetsAsync(userId);

            if (budgets == null || !budgets.Any())
                return Result<IEnumerable<CategoryBudgetResponse>>.Success(Enumerable.Empty<CategoryBudgetResponse>());

            var budgetsResponse = budgets.Select(budget => MapBudgetToBudgetResponse(budget)).ToList();

            return Result<IEnumerable<CategoryBudgetResponse>>.Success(budgetsResponse);
        }

        public async Task<Result<CategoryBudgetResponse>> GetCategoryBudgetAsync(int userId, int categoryId)
        {
            var budget = await _budgetRepo.GetCategoryBudgetAsync(userId, categoryId);

            if (budget == null)
                return Result<CategoryBudgetResponse>.Failure("Category budget was not found.", enErrorType.NotFound);

            return Result<CategoryBudgetResponse>.Success(MapBudgetToBudgetResponse(budget));
        }

        // Writing methods --------------------------------------------------
        public async Task<Result<CategoryBudgetResponse>> SetCategoryBudgetAsync(CategoryBudgetDTO budgetDto)
        {
            // 1 - Input validations --------------------------------------------
            if (SystemCategories.GetById(budgetDto.CategoryId) == null)
                return Result<CategoryBudgetResponse>.Failure("Invalid category.", enErrorType.Validation);

            if (budgetDto.PercentageLimit <= 0)
                return Result<CategoryBudgetResponse>.Failure("Budget percentage limit must be greater than zero.", enErrorType.Validation);

            if (budgetDto.StartDate >= budgetDto.EndDate)
                return Result<CategoryBudgetResponse>.Failure("The start date must occur prior to the end date.", enErrorType.Validation);

            budgetDto.CategoryBudgetId = -1; // Make sure to send -1 to database (safe practice)

            // 2 - Map data ------------------------------------------------------
            var newBudget = MapBudgetDTOtoBudgetObject(budgetDto);

            int newBudgetId = await _budgetRepo.SetCategoryBudgetAsync(budgetDto.UserId, newBudget);

            if (newBudgetId == -1)
                return Result<CategoryBudgetResponse>.Failure("Failed to save the category budget to the database.", enErrorType.Failure);

            // Create tracking entity instance containing the real database generated identifier
            var budgetWithId = new CategoryBudget(
                newBudgetId,
                newBudget.UserId,
                newBudget.CategoryId,
                newBudget.PercentageLimit,
                newBudget.PercentageProgress,
                newBudget.StartDate,
                newBudget.EndDate,
                newBudget.IsActive
            );

            // 3 - Form the response ----------------------------------------------
            return Result<CategoryBudgetResponse>.Success(MapBudgetToBudgetResponse(budgetWithId));
        }

        public async Task<Result<CategoryBudgetResponse>> UpdateCategoryBudgetAsync(CategoryBudgetDTO budgetDto)
        {
            // 1 - Input validations --------------------------------------------
            if (SystemCategories.GetById(budgetDto.CategoryId) == null)
                return Result<CategoryBudgetResponse>.Failure("Invalid category.", enErrorType.Validation);

            if (budgetDto.PercentageLimit <= 0)
                return Result<CategoryBudgetResponse>.Failure("Budget percentage limit must be greater than zero.", enErrorType.Validation);

            if (budgetDto.StartDate >= budgetDto.EndDate)
                return Result<CategoryBudgetResponse>.Failure("The start date must occur prior to the end date.", enErrorType.Validation);

            // Verify budget existence before trying to update
            var existingBudget = await _budgetRepo.GetCategoryBudgetAsync(budgetDto.UserId, budgetDto.CategoryId);
            if (existingBudget == null)
                return Result<CategoryBudgetResponse>.Failure("Category budget was not found.", enErrorType.NotFound);

            // Keep identity context aligned 
            budgetDto.CategoryBudgetId = existingBudget.CategoryBudgetId;

            // 2 - Map data ------------------------------------------------------
            var updatedBudget = MapBudgetDTOtoBudgetObject(budgetDto);

            if (!await _budgetRepo.UpdateCategoryBudgetAsync(updatedBudget))
                return Result<CategoryBudgetResponse>.Failure("Failed to update the category budget in the database.", enErrorType.Failure);

            // 3 - Form the response ----------------------------------------------
            return Result<CategoryBudgetResponse>.Success(MapBudgetToBudgetResponse(updatedBudget));
        }

        public async Task<Result> DeleteCategoryBudgetAsync(int userId, int categoryId)
        {
            if (await _budgetRepo.DeleteCategoryBudgetAsync(userId, categoryId))
                return Result.Success();

            return Result.Failure("Failed to delete the category budget from the database.", enErrorType.Failure);
        }
    }
}