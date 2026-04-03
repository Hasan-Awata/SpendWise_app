using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.Interfaces.Incom;
using SpendWise.Application.Interfaces.Tags;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/incoms")]

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
            int userId = CurrentUserId;

            var income = await _incomeService.GetIncomeAsync(userId, incomeId);

            if (income == null)
            {
                return NotFound();
            }

            return Ok(income);
        }

        [HttpGet]
        // Multiple routes for the same data
        // we use [FromQuery] instead of [FromRoute] for the categoryId
        public async Task<IActionResult> GetIncomes([FromQuery] bool? isFixed)
        {
            int userId = CurrentUserId;

            if (isFixed.HasValue)
            {
                // Triggered by: GET /api/incomes?Type=5
                var tags = await _incomeService.GetIncomesByTypeAsync(userId, isFixed);
                return Ok(tags);
            }
            else
            {
                // Triggered by: GET /api/incomes
                var tags = await _incomeService.GetIncomesByUserIdAsync(userId);
                return Ok(tags);
            }
        }


    }
}
