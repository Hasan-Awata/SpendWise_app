using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs;
using SpendWise.Application.Interfaces;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [ApiController]
    [Route("api/users/{userId}/tags")]
    public class TagController : ControllerBase
    {
        private readonly ITagService _tagService;

        public TagController(ITagService tagService)
        {
            _tagService = tagService;
        }

        [HttpGet("{tagId}")]
        public async Task<IActionResult> GetTag([FromRoute] int userId, [FromRoute] int tagId)
        {
            var tag = await _tagService.GetTagAsync(tagId);

            if (tag == null)
            {
                return NotFound();
            }

            return Ok(tag);
        }

        [HttpGet]
        // Multiple routes for the same data
        // we use [FromQuery] instead of [FromRoute] for the categoryId
        public async Task<IActionResult> GetTags([FromRoute] int userId, [FromQuery] int? categoryId)
        {
            if (categoryId.HasValue)
            {
                // Triggered by: GET /api/users/1/tags?categoryId=5
                var tags = await _tagService.GetTagsByCategoryIdAsync(userId, categoryId.Value);
                return Ok(tags);
            }
            else
            {
                // Triggered by: GET /api/users/1/tags
                var tags = await _tagService.GetTagsByUserIdAsync(userId);
                return Ok(tags);
            }
        }

        [HttpPost]
        public async Task<IActionResult> AddTag([FromRoute] int userId, [FromBody] TagDTO tagDto)
        {
            tagDto.OwnerId = userId;

            await _tagService.AddTagAsync(tagDto);

            // This generates a 201 status and a Location header like:
            // Location: https://mydomain.com/api/users/1/tags/5
            return CreatedAtAction(
                nameof(GetTag),                                   // 1. Action Name
                new { userId = userId, tagId = tagDto.Id },       // 2. Route Values
                tagDto                                            // 3. Response Body
            );
        }

        [HttpPatch("{tagId}")]
        public async Task<IActionResult> UpdateTag([FromRoute] int userId, [FromRoute] int tagId, [FromBody] TagDTO tagDto)
        {
            // 1. Guard against mismatched IDs (Optional but highly recommended)
            if (tagDto.Id != 0 && tagDto.Id != tagId)
            {
                return BadRequest("The tag ID in the body does not match the URL.");
            }

            // 2. Force the DTO to match the URL parameters
            tagDto.Id = tagId;
            tagDto.OwnerId = userId;

            await _tagService.UpdateTagAsync(tagDto);

            return NoContent();
        }

        [HttpDelete("{tagId}")]
        public async Task<IActionResult> DeleteTag([FromRoute] int userId, [FromRoute] int tagId)
        {
            await _tagService.DeleteTagAsync(tagId);

            return NoContent();
        }
    }
}