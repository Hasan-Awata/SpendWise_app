using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Application.Interfaces.OcrScanning;
using SpendWise.Domain.Common;
using SpendWise.Domain.Enums;
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

        protected ActionResult HandleResult<T>(Result<T> result)
        {
            var errorResponse = new { message = result.ErrorMessage };

            return result.ErrorType switch
            {
                enErrorType.Validation => BadRequest(errorResponse),
                enErrorType.NotFound => NotFound(errorResponse),
                enErrorType.BalanceViolation => UnprocessableEntity(errorResponse),
                _ => StatusCode(500, new { message = errorResponse })
            };
        }
        protected ActionResult HandleResult(Result result)
        {
            var errorResponse = new { message = result.ErrorMessage };

            return result.ErrorType switch
            {
                enErrorType.Validation => BadRequest(errorResponse),
                enErrorType.NotFound => NotFound(errorResponse),
                enErrorType.BalanceViolation => UnprocessableEntity(errorResponse),
                _ => StatusCode(500, new { message = errorResponse })
            };
        }

        [HttpGet("{expenseId}")]
        public async Task<IActionResult> GetExpense([FromRoute] int expenseId)
        {
            var result = await _expenseService.GetExpenseAsync(expenseId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResult(result);
            }
            var expenseResponse = result.Value;
            
            return Ok(expenseResponse);
        }

        [HttpGet]
        public async Task<IActionResult> GetExpenseByUser([FromQuery] PageDTO pageDTO)
        {
            var result = await _expenseService.GetExpenseByUserAsync(CurrentUserId, pageDTO);

            var pagedExpensesList = result.Value;

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

            var result = await _expenseService.AddExpenseAsync(expenseDTO);

            if (!result.IsSuccess)
            {
                return HandleResult(result);
            }
            var createdExpense = result.Value;
            
            return CreatedAtAction(nameof(GetExpense), new { expenseId = createdExpense!.ExpenseId }, createdExpense);
        }

        [HttpPatch("{expenseId}")]
        public async Task<IActionResult> UpdateExpense([FromRoute] int expenseId, [FromBody] ExpenseDTO expenseDTO)
        {
            if (CurrentUserId != expenseDTO.UserId) return Unauthorized();

            expenseDTO.ExpenseId = expenseId; 

            var result = await _expenseService.UpdateExpenseAsync(expenseDTO);

            if (!result.IsSuccess)
            {
                return HandleResult(result);
            }
            var updatedExpense = result.Value;

            return Ok(updatedExpense);
        }

        [HttpDelete("{expenseId}")]
        public async Task<IActionResult> DeleteExpense([FromRoute] int expenseId)
        {
            var result = await _expenseService.DeleteExpenseAsync(expenseId, CurrentUserId);

            if(!result.IsSuccess)
                return HandleResult(result);

            return NoContent();
        }
    }
}
