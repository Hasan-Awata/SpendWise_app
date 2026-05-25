using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Tags;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/tags")]
    public class TagController : BaseApiController
    {
        private readonly ITagService _tagService;

        public TagController(ITagService tagService)
        {
            _tagService = tagService;
        }

        // Endpoints --------------------------------------------------------
        [HttpGet("{tagId}")]
        public async Task<IActionResult> GetTag([FromRoute] int tagId)
        {
            var result = await _tagService.GetTagAsync(tagId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet]
        public async Task<IActionResult> GetTags()
        {
            var result = await _tagService.GetTagsByUserIdAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost]
        public async Task<IActionResult> AddTag([FromBody] TagDTO tagDto)
        {
            if (CurrentUserId != tagDto.OwnerId)
            {
                return Unauthorized();
            }

            tagDto.OwnerId = CurrentUserId;

            var result = await _tagService.AddTagAsync(tagDto);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            var createdTag = result.Value;

            return CreatedAtAction(nameof(GetTag), new { tagId = createdTag!.Id }, createdTag);
        }

        [HttpPatch("{tagId}")]
        public async Task<IActionResult> UpdateTag([FromRoute] int tagId, [FromBody] TagDTO tagDto)
        {
            if (CurrentUserId != tagDto.OwnerId)
            {
                return Unauthorized();
            }

            // Route parameters securely overwrite body parameters 
            tagDto.Id = tagId;
            tagDto.OwnerId = CurrentUserId;

            var result = await _tagService.UpdateTagAsync(tagDto);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpDelete("{tagId}")]
        public async Task<IActionResult> DeleteTag([FromRoute] int tagId)
        {
            var result = await _tagService.DeleteTagAsync(tagId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return NoContent();
        }
    }
}