using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Common;

namespace SpendWise.Application.Interfaces.Categories
{
    public interface ICategoryBudgetService
    {
        public Task<Result<IEnumerable<CategoryBudgetResponse>>> GetAllUserBudgetsAsync(int userId);

        public Task<Result<CategoryBudgetResponse>> GetCategoryBudgetAsync(int userId, int categoryId);

        public Task<Result<CategoryBudgetResponse>> SetCategoryBudgetAsync(CategoryBudgetDTO budgetDto);

        public Task<Result<CategoryBudgetResponse>> UpdateCategoryBudgetAsync(CategoryBudgetDTO budgetDto);

        public Task<Result> DeleteCategoryBudgetAsync(int userId, int categoryId);
    }
}
