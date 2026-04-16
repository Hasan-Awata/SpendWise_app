using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.Interfaces.Incomes;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/incomes")]

    public class IncomeController : Controller
    {
        private readonly IIncomeService _incomeService;
            
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
        public IncomeController(IIncomeService incomeService)
        {
            _incomeService = incomeService;
        }

        [HttpGet("{incomeId}")]
        public async Task<IActionResult> GetIncome([FromRoute] int incomeId)
        {
            var incomeResponse = await _incomeService.GetIncomeAsync(incomeId, CurrentUserId);

            if (incomeResponse == null)
            {
                return NotFound();
            }

            return Ok(incomeResponse);
        }

        [HttpGet]
        public async Task<IActionResult> GetIncomeByUser([FromQuery] PageDTO pageDTO)
        {
            var pagedIncomeList = await _incomeService.GetIncomeByUserAsync(CurrentUserId, pageDTO);

            return Ok(pagedIncomeList);
        }

        [HttpPost]
        public async Task<IActionResult> AddIncome([FromBody] IncomeDTO incomeDTO)
        {
            if (CurrentUserId != incomeDTO.UserId)
            {
                return Unauthorized();
            }

            incomeDTO.UserId = CurrentUserId;

            var createdIncome = await _incomeService.AddIncomeAsync(incomeDTO);

            if (createdIncome == null)
            {
                return BadRequest();
            }

            return CreatedAtAction(nameof(GetIncome), incomeDTO);
        }

        [HttpPatch("{incomeId}")]
        public async Task<IActionResult> UpdateIncome([FromRoute] int incomeId, [FromBody] IncomeDTO incomeDTO)
        {
            if(CurrentUserId != incomeDTO.UserId)
            {
                return Unauthorized();
            }

            incomeDTO.UserId = CurrentUserId;

            var createdIncome = await _incomeService.AddIncomeAsync(incomeDTO);

            if (createdIncome == null)
            {
                return BadRequest();
            }

            return CreatedAtAction("Income was created successfully", createdIncome);
        }

        [HttpDelete("{incomeId}")]
        public async Task<IActionResult> DeleteIncome([FromRoute] int incomeId)
        {
            if(await _incomeService.DeleteIncomeAsync(incomeId))
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
