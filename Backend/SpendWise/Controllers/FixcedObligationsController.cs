using Azure;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.FixedObligations;
using SpendWise.Application.Interfaces.FixedObligations;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Application.Services;
using SpendWise.Domain.Entities;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/fixed-obligations")]
    public class FixedObligationsController : ControllerBase
    {
        private readonly IFixedObligationsService _fixedObligationService;

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
        public FixedObligationsController(IFixedObligationsService fixedObligationService)
        {
            _fixedObligationService = fixedObligationService;
        }

        [HttpGet("{fixedObligationId}")]
        public async Task<IActionResult> GetFixedObligation([FromRoute] int fixedObligationId)
        {
            int userId = CurrentUserId;

            var fixedObligation = _fixedObligationService.GetFixedObligationAsync(fixedObligationId, userId);

            if (fixedObligation == null)
            {
                return NotFound();
            }

            return Ok(fixedObligation);
        }

        [HttpGet]
        public async Task<IActionResult> GetUserFixedObligations()
        {
            int userId = CurrentUserId;

            var fixedObligationsList = _fixedObligationService.GetFixedObligationsByUserIdAsync(userId);
            
            return Ok(fixedObligationsList);
        }

        [HttpPost]
        public async Task<IActionResult> CreateFixedObligationAsync([FromBody] FixedObligationDTO fixedObligationDTO)
        {
            if (fixedObligationDTO.OwnerId == CurrentUserId)
                return Unauthorized();

            await _fixedObligationService.CreateFixedObligationAsync(fixedObligationDTO); // make this return boolean later

            // This generates a 201 status and a Location header like:
            // Location: https://mydomain.com/api/fixed-obligations/5
            return CreatedAtAction(
                nameof(GetFixedObligation),                     // 1. Action Name
                new { obligationId = fixedObligationDTO.Id },   // 2. Route Values
                fixedObligationDTO                              // 3. Response Body
            );
        }

        [HttpPatch("{fixedObligationId}")]
        public async Task<IActionResult> UpdateFixedObligation([FromRoute] int fixedObligationId, 
            [FromBody] FixedObligationDTO fixedObligationDTO)
        {
            if (fixedObligationDTO.OwnerId != CurrentUserId)
            {
                return Unauthorized();
            }

            int userId = CurrentUserId;

            // 1. Guard against mismatched IDs 
            if (fixedObligationDTO.Id != 0 && fixedObligationDTO.Id != fixedObligationId)
                return BadRequest("The tag ID in the body does not match the URL.");

            // 2. Force the DTO to match the URL parameters
            fixedObligationDTO.Id = fixedObligationId;
            fixedObligationDTO.OwnerId = CurrentUserId;

            await _fixedObligationService.UpdateFixedObligationAsync(fixedObligationDTO);

            return NoContent();
        }

        [HttpDelete("{fixedObligationId}")]
        public async Task<IActionResult> DeleteTag([FromRoute] int fixedObligationId)
        {
            int userId = CurrentUserId;

            await _fixedObligationService.DeleteFixedObligationAsync(fixedObligationId, userId);

            return NoContent();
        }

    }
}

