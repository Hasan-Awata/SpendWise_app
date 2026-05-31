using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.FixedIncome;
using SpendWise.Application.Interfaces;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/fixed-incomes")]
    public class FixedIncomeController : ControllerBase
    {
        private readonly IFixedIncomeService _fixedIncomeService;

        // Helper property to securely extract the user ID from the auth token
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

        public FixedIncomeController(IFixedIncomeService fixedIncomeService)
        {
            _fixedIncomeService = fixedIncomeService;
        }

        [HttpGet("{fixedIncomeId}")]
        public async Task<IActionResult> GetFixedIncome([FromRoute] int fixedIncomeId)
        {
            var response = await _fixedIncomeService.GetFixedIncomeAsync(fixedIncomeId, CurrentUserId);

            if (response == null)
            {
                return NotFound();
            }

            return Ok(response);
        }

        [HttpGet]
        public async Task<IActionResult> GetFixedIncomesByUser()
        {
            var fixedIncomes = await _fixedIncomeService.GetFixedIncomesByUserIdAsync(CurrentUserId);
            return Ok(fixedIncomes);
        }

        [HttpPost]
        public async Task<IActionResult> CreateFixedIncome([FromBody] FixedIncomeDTO fixedIncomeDTO)
        {
            // Ensure the user is creating a record for themselves
            fixedIncomeDTO.UserId = CurrentUserId;

            var createdId = await _fixedIncomeService.CreateFixedIncomeAsync(fixedIncomeDTO);

            if (createdId == -1)
            {
                return BadRequest("Failed to create fixed income.");
            }

            // Return the created ID or the full object if your service returns it
            return CreatedAtAction(nameof(GetFixedIncome), new { fixedIncomeId = createdId }, fixedIncomeDTO);
        }

        [HttpPatch]
        public async Task<IActionResult> UpdateFixedIncome([FromBody] FixedIncomeDTO fixedIncomeDTO)
        {
            fixedIncomeDTO.UserId = CurrentUserId;

            await _fixedIncomeService.UpdateFixedIncomeAsync(fixedIncomeDTO);

            return Ok(new { message = "Fixed income updated successfully" });
        }

        [HttpDelete("{fixedIncomeId}")]
        public async Task<IActionResult> DeleteFixedIncome([FromRoute] int fixedIncomeId)
        {
            // Note: Service returns void/Task in your example, but you can adjust 
            // the service to return bool if you want to handle "NoContent" vs "BadRequest"
            await _fixedIncomeService.DeleteFixedIncomeAsync(fixedIncomeId, CurrentUserId);

            return NoContent();
        }

        [HttpGet("{fixedIncomeId}/status")]
        public async Task<IActionResult> IsFixedIncomeActive([FromRoute] int fixedIncomeId)
        {

            var isActive = await _fixedIncomeService.IsFixedIncomeActive(fixedIncomeId,CurrentUserId);
            return Ok(new { FixedIncomeId = fixedIncomeId, IsActive = isActive });
        }
    }
}