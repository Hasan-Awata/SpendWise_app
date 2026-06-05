using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.FixedObligations;
using SpendWise.Application.Interfaces.FixedObligations;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/fixed-obligations")]
    public class FixedObligationsController : BaseApiController
    {
        private readonly IFixedObligationsService _fixedObligationsService;

        public FixedObligationsController(IFixedObligationsService fixedObligationsService)
        {
            _fixedObligationsService = fixedObligationsService;
        }

        [HttpGet("{fixedObligationId:int}")]
        public async Task<IActionResult> GetFixedObligation([FromRoute] int fixedObligationId)
        {
            var response = await _fixedObligationsService.GetFixedObligationAsync(fixedObligationId, CurrentUserId);

            if (response == null)
            {
                return NotFound(new { message = "Fixed obligation not found." });
            }

            return Ok(response);
        }

        [HttpGet]
        public async Task<IActionResult> GetFixedObligationsByUser()
        {
            var fixedObligations = await _fixedObligationsService.GetFixedObligationsByUserIdAsync(CurrentUserId);
            return Ok(fixedObligations);
        }

        [HttpPost]
        public async Task<IActionResult> CreateFixedObligation([FromBody] FixedObligationDTO fixedObligationDto)
        {
            fixedObligationDto.UserId = CurrentUserId;

            var createdId = await _fixedObligationsService.CreateFixedObligationAsync(fixedObligationDto);

            if (createdId == -1)
            {
                return BadRequest(new { message = "Failed to create fixed obligation." });
            }

            var createdObligation = await _fixedObligationsService.GetFixedObligationAsync(createdId, CurrentUserId);

            return CreatedAtAction(nameof(GetFixedObligation), new { fixedObligationId = createdId }, createdObligation);
        }

        [HttpPatch("{fixedObligationId:int}")]
        public async Task<IActionResult> UpdateFixedObligation([FromRoute] int fixedObligationId, [FromBody] FixedObligationDTO fixedObligationDto)
        {
            fixedObligationDto.UserId = CurrentUserId;

            var isUpdated = await _fixedObligationsService.UpdateFixedObligationAsync(fixedObligationId, fixedObligationDto);

            if (!isUpdated)
            {
                return BadRequest(new { message = "Failed to update fixed obligation. It may not exist or validation failed." });
            }

            var updatedObligation = await _fixedObligationsService.GetFixedObligationAsync(fixedObligationId, CurrentUserId);

            return Ok(updatedObligation);
        }

        [HttpDelete("{fixedObligationId:int}")]
        public async Task<IActionResult> DeleteFixedObligation([FromRoute] int fixedObligationId)
        {
            var isDeleted = await _fixedObligationsService.DeleteFixedObligationAsync(fixedObligationId, CurrentUserId);

            if (!isDeleted)
            {
                return BadRequest(new { message = "Failed to delete fixed obligation." });
            }

            return NoContent();
        }

        [HttpGet("{fixedObligationId:int}/status")]
        public async Task<IActionResult> IsFixedObligationActive([FromRoute] int fixedObligationId)
        {
            var isActive = await _fixedObligationsService.IsFixedObligationActive(fixedObligationId, CurrentUserId);
            return Ok(new { FixedObligationId = fixedObligationId, IsActive = isActive });
        }
    }
}