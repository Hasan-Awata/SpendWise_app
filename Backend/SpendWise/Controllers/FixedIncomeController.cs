using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.FixedIncome;
using SpendWise.Application.Interfaces;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/fixed-incomes")]
    public class FixedIncomeController : BaseApiController
    {
        private readonly IFixedIncomeService _fixedIncomeService;

        public FixedIncomeController(IFixedIncomeService fixedIncomeService)
        {
            _fixedIncomeService = fixedIncomeService;
        }

        [HttpGet("{FixedIncomeId:int}")]
        public async Task<IActionResult> GetFixedIncome([FromRoute] int FixedIncomeId)
        {
            var response = await _fixedIncomeService.GetFixedIncomeAsync(FixedIncomeId, CurrentUserId);

            if (response == null)
            {
                return NotFound(new { message = "Fixed income not found." });
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
            fixedIncomeDTO.UserId = CurrentUserId;

            var createdId = await _fixedIncomeService.CreateFixedIncomeAsync(fixedIncomeDTO);

            if (createdId == -1)
            {
                return BadRequest(new { message = "Failed to create fixed income." });
            }

            var createdIncome = await _fixedIncomeService.GetFixedIncomeAsync(createdId, CurrentUserId);

            return CreatedAtAction(nameof(GetFixedIncome), new { fixedIncomeId = createdId }, createdIncome);
        }

         [HttpPatch("{fixedIncomeId:int}")]
        public async Task<IActionResult> UpdateFixedIncome([FromRoute] int fixedIncomeId, [FromBody] FixedIncomeDTO fixedIncomeDTO)
        {
            fixedIncomeDTO.UserId = CurrentUserId;

            var isUpdated = await _fixedIncomeService.UpdateFixedIncomeAsync(fixedIncomeId, fixedIncomeDTO);

            if (!isUpdated)
            {
                return BadRequest(new { message = "Failed to update fixed income. It may not exist or validation failed." });
            }

             var updatedIncome = await _fixedIncomeService.GetFixedIncomeAsync(fixedIncomeId, CurrentUserId);

            return Ok(updatedIncome);
        }

        [HttpDelete("{fixedIncomeId:int}")]
        public async Task<IActionResult> DeleteFixedIncome([FromRoute] int fixedIncomeId)
        {
            var isDeleted = await _fixedIncomeService.DeleteFixedIncomeAsync(fixedIncomeId, CurrentUserId);

            if (!isDeleted)
            {
                return BadRequest(new { message = "Failed to delete fixed income." });
            }

            return NoContent();
        }

        [HttpGet("{fixedIncomeId:int}status")]
        public async Task<IActionResult> IsFixedIncomeActive([FromRoute] int fixedIncomeId)
        {
            var isActive = await _fixedIncomeService.IsFixedIncomeActive(fixedIncomeId, CurrentUserId);
            return Ok(new { FixedIncomeId = fixedIncomeId, IsActive = isActive });
        }
    }
}