using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Tags;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/tags")]
    public class TagController : ControllerBase
    {
        private readonly ITagService _tagService;

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
        public TagController(ITagService tagService)
        {
            _tagService = tagService;
        }

        [HttpGet("{tagId}")]
        public async Task<IActionResult> GetTag([FromRoute] int tagId)
        {
            int userId = CurrentUserId;

            var tag = await _tagService.GetTagAsync(userId, tagId);

            if (tag == null)
            {
                return NotFound();
            }

            return Ok(tag);
        }

        [HttpGet]
        // Multiple routes for the same data
        // we use [FromQuery] instead of [FromRoute] for the categoryId
        public async Task<IActionResult> GetTags()
        {
            int userId = CurrentUserId;

            // Triggered by: GET /api/tags
            var tags = await _tagService.GetTagsByUserIdAsync(userId);
            return Ok(tags);
        }

        [HttpPost]
        public async Task<IActionResult> AddTag([FromBody] TagDTO tagDto)
        {
            tagDto.OwnerId = CurrentUserId;

            await _tagService.AddTagAsync(tagDto);

            // This generates a 201 status and a Location header like:
            // Location: https://mydomain.com/api/tags/5
            return CreatedAtAction(
                nameof(GetTag),                // 1. Action Name
                new {tagId = tagDto.Id },      // 2. Route Values
                tagDto                         // 3. Response Body
            );
        }

        [HttpPatch("{tagId}")]
        public async Task<IActionResult> UpdateTag([FromRoute] int tagId, [FromBody] TagDTO tagDto)
        {
            if (tagDto.OwnerId != CurrentUserId)
                return Unauthorized();

            if (tagDto.OwnerId != CurrentUserId) return Unauthorized("You do not have permission to update this tag.");

            // 1. Guard against mismatched IDs (Optional but highly recommended)
            if (tagDto.Id != 0 && tagDto.Id != tagId)
                return BadRequest("The tag ID in the body does not match the URL.");

            // 2. Force the DTO to match the URL parameters
            tagDto.Id = tagId;
            tagDto.OwnerId = CurrentUserId;

            await _tagService.UpdateTagAsync(tagDto);

            return NoContent();
        }

        [HttpDelete("{tagId}")]
        public async Task<IActionResult> DeleteTag([FromRoute] int tagId)
        {
            int userId = CurrentUserId;

            await _tagService.DeleteTagAsync(tagId, userId);

            return NoContent();
        }
    }
}