using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.Categories;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/categories/budgets")] 
    public class CategoryBudgetController : ControllerBase
    {
        private readonly ICategoryBudgetService _budgetService;
        private int CurrentUserId
        {
            get
            {
                var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (int.TryParse(userIdString, out int userId))
                {
                    return userId;
                }
                throw new UnauthorizedAccessException("User ID claim is missing or invalid.");
            }
        }

        public CategoryBudgetController(ICategoryBudgetService budgetService) => _budgetService = budgetService;

        [HttpGet] 
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllBudgets()
        {
            return Ok(await _budgetService.GetAllUserBudgetsAsync(CurrentUserId));
        }

        [HttpGet("{categoryId}")] 
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetBudgetById([FromRoute] int categoryId)
        {
            var budget = await _budgetService.GetCategoryBudgetAsync(CurrentUserId, categoryId);
            return (budget == null || budget.UserId != CurrentUserId) ? NotFound() : Ok(budget);
        }

        [HttpPost] 
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> AddBudget([FromBody] CategoryBudgetDTO budgetDto)
        {
            if (budgetDto.UserId != CurrentUserId) return Unauthorized();

            var budgetId = await _budgetService.SetCategoryBudgetAsync(budgetDto);
            return budgetId <= 0 ? BadRequest() : CreatedAtAction(nameof(GetBudgetById), new { budgetId }, budgetId);
        }

        [HttpPatch("{categoryId}")] 
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> UpdateBudget([FromRoute] int categoryId, [FromBody] CategoryBudgetDTO budgetDto) 
        {
            if (budgetDto.UserId != CurrentUserId) return Unauthorized();

            budgetDto.CategoryId = categoryId;

            return await _budgetService.UpdateCategoryBudgetAsync(budgetDto) ? NoContent() : BadRequest();
        }

        [HttpDelete("{categoryId}")] 
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> DeleteBudget([FromRoute] int categoryId) 
        {
            return await _budgetService.DeleteCategoryBudgetAsync(CurrentUserId, categoryId) ? NoContent() : BadRequest();
        }
    }
}