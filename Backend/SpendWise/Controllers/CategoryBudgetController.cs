using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.Categories;
using SpendWise.Domain.Common;
using SpendWise.Domain.Enums;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/categories/budgets")]
    public class CategoryBudgetController : BaseApiController
    {
        private readonly ICategoryBudgetService _budgetService;

        public CategoryBudgetController(ICategoryBudgetService budgetService)
        {
            _budgetService = budgetService;
        }

        // Endpoints --------------------------------------------------------
        [HttpGet]
        public async Task<IActionResult> GetAllBudgets()
        {
            var result = await _budgetService.GetAllUserBudgetsAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet("{categoryId}")]
        public async Task<IActionResult> GetBudgetById([FromRoute] int categoryId)
        {
            var result = await _budgetService.GetCategoryBudgetAsync(CurrentUserId, categoryId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost]
        public async Task<IActionResult> AddBudget([FromBody] CategoryBudgetDTO budgetDto)
        {
            if (CurrentUserId != budgetDto.UserId)
            {
                return Unauthorized();
            }

            budgetDto.UserId = CurrentUserId;

            var result = await _budgetService.SetCategoryBudgetAsync(budgetDto);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            var createdBudget = result.Value;

            return CreatedAtAction(nameof(GetBudgetById), new { categoryId = createdBudget!.CategoryId }, createdBudget);
        }

        [HttpPatch("{categoryId}")]
        public async Task<IActionResult> UpdateBudget([FromRoute] int categoryId, [FromBody] CategoryBudgetDTO budgetDto)
        {
            if (CurrentUserId != budgetDto.UserId)
            {
                return Unauthorized();
            }

            // Route parameters securely override body payload properties
            budgetDto.CategoryId = categoryId;
            budgetDto.UserId = CurrentUserId;

            var result = await _budgetService.UpdateCategoryBudgetAsync(budgetDto);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpDelete("{categoryId}")]
        public async Task<IActionResult> DeleteBudget([FromRoute] int categoryId)
        {
            var result = await _budgetService.DeleteCategoryBudgetAsync(CurrentUserId, categoryId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return NoContent();
        }
    }
}