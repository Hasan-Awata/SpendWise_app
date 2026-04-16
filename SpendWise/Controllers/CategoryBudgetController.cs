using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.CategoryBudget;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/CategoryBudget")]
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

        [HttpGet("GetAllBudgets")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllBudgets()
        {
            return Ok(await _budgetService.GetAllUserBudgetsAsync(CurrentUserId));
        }

        [HttpGet("GetBudgetById/{budgetId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetBudgetById([FromRoute] int budgetId)
        {
            var budget = await _budgetService.GetCategoryBudgetByIdAsync(budgetId);
            return (budget == null || budget.UserId != CurrentUserId) ? NotFound() : Ok(budget);
        }

        [HttpPost("AddBudget/{budgetDto}")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> AddBudget([FromBody] CategoryBudgetDTO budgetDto)
        {
            var budgetId = await _budgetService.AddCategoryBudgetAsync(CurrentUserId, budgetDto);
            return budgetId <= 0 ? BadRequest() : CreatedAtAction(nameof(GetBudgetById), new { budgetId }, budgetId);
        }

        [HttpPatch("UpdateBudget/{budgetId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UpdateBudget([FromRoute] int budgetId, [FromBody] CategoryBudgetDTO budgetDto)
        {
            var existing = await _budgetService.GetCategoryBudgetByIdAsync(budgetId);
            if (existing == null || existing.UserId != CurrentUserId) return NotFound();

            return await _budgetService.UpdateCategoryBudgetAsync(budgetId, budgetDto) ? NoContent() : BadRequest();
        }

        [HttpDelete("DeleteBudget/{budgetId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> DeleteBudget([FromRoute] int budgetId)
        {
            var existing = await _budgetService.GetCategoryBudgetByIdAsync(budgetId);
            if (existing == null || existing.UserId != CurrentUserId) return NotFound();

            return await _budgetService.DeleteCategoryBudgetAsync(budgetId) ? NoContent() : BadRequest();
        }
        [HttpDelete("IsExistBudget/{budgetId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> IsExistBudget([FromRoute] int budgetId)
        {
            if(budgetId<=0) return BadRequest();
            return (await _budgetService.CategoryBudgetExistsAsync(budgetId)) ? Ok() : NotFound();
        }



    }
}
