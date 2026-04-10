using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.Interfaces.Expenses;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/expenses")]

    public class ExpenseController : Controller
    {
        private readonly IExpenseService _expenseService;

        // Helper property to securely extract the user ID from the auth token
        private int CurrentUserId
        {
            get
            {
                // 1. Get the string value from the claim
                var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                // 2. Safely attempt to parse it into an integer
                if (int.TryParse(userIdString, out int userId))
                {
                    return userId;
                }

                // 3. Fallback/Safety Net: If the claim is missing or somehow isn't a valid number
                throw new UnauthorizedAccessException("User ID claim is missing or invalid.");
            }
        }
        public ExpenseController(IExpenseService expenseService)
        {
            _expenseService = expenseService;
        }

        [HttpGet("{expenseId}")]
        public async Task<IActionResult> GetExpense([FromRoute] int expenseId)
        {
            var expenseResponse = await _expenseService.GetExpenseAsync(expenseId, CurrentUserId);

            if (expenseResponse == null)
            {
                return NotFound();
            }

            return Ok(expenseResponse);
        }

        [HttpGet]
        public async Task<IActionResult> GetExpenseByUser([FromQuery] PageDTO pageDTO)
        {
            var pagedExpensesList = await _expenseService.GetExpenseByUserAsync(CurrentUserId, pageDTO);

            return Ok(pagedExpensesList);
        }

        [HttpPost]
        public async Task<IActionResult> AddExpense([FromBody] ExpenseDTO expenseDTO)
        {
            if (CurrentUserId != expenseDTO.UserId)
            {
                return Unauthorized();
            }

            expenseDTO.UserId = CurrentUserId;

            var createdExpense = await _expenseService.AddExpenseAsync(expenseDTO);

            if (createdExpense == null)
            {
                return BadRequest();
            }

            return CreatedAtAction(nameof(GetExpense), expenseDTO);
        }

        [HttpPatch("{expenseId}")]
        public async Task<IActionResult> UpdateExpense([FromRoute] int expenseId, [FromBody] ExpenseDTO expenseDTO)
        {
            if (CurrentUserId != expenseDTO.UserId)
            {
                return Unauthorized();
            }

            expenseDTO.UserId = CurrentUserId;

            var createdExpense = await _expenseService.AddExpenseAsync(expenseDTO);

            if (createdExpense == null)
            {
                return BadRequest();
            }

            return CreatedAtAction(nameof(GetExpense), expenseDTO);
        }

        [HttpDelete("{expenseId}")]
        public async Task<IActionResult> DeleteIncome([FromRoute] int expenseId)
        {
            if (await _expenseService.DeleteExpenseAsync(expenseId))
            {
                return NoContent();
            }
            else
            {
                return BadRequest();
            }
        }
    }
}
