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

    public class ExpenseController : BaseApiController
    {
        private readonly IExpenseService _expenseService;

        public ExpenseController(IExpenseService expenseService)
        {
            _expenseService = expenseService;
        }

        [HttpGet("{expenseId}")]
        public async Task<IActionResult> GetExpense([FromRoute] int expenseId)
        {
            var result = await _expenseService.GetExpenseAsync(expenseId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }
            var expenseResponse = result.Value;
            
            return Ok(expenseResponse);
        }

        [HttpGet]
        public async Task<IActionResult> GetExpenseByUser([FromQuery] PageDTO pageDTO)
        {
            var result = await _expenseService.GetExpenseByUserAsync(CurrentUserId, pageDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
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
                return HandleResultOnError(result);
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
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpDelete("{expenseId}")]
        public async Task<IActionResult> DeleteExpense([FromRoute] int expenseId)
        {
            var result = await _expenseService.DeleteExpenseAsync(expenseId, CurrentUserId);

            if(!result.IsSuccess)
                return HandleResultOnError(result);

            return NoContent();
        }
    }
}
