using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Domain.Common;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;

namespace SpendWise.Application.Services
{
    public class TagService : ITagService
    {
        private readonly ITagRepository _tagRepo;

        public TagService(ITagRepository tagRepository)
        {
            _tagRepo = tagRepository;
        }

        // Helpers methods --------------------------------------------------
        private Tag MapTagDTOtoTagObject(TagDTO tagDto)
        {
            // Utilizing the Domain Entity constructor as requested
            return new Tag(tagDto.Id, tagDto.OwnerId, tagDto.Label);
        }

        private TagResponse MapTagToTagResponse(Tag tag)
        {
            return new TagResponse
            (
                tag.Id,
                tag.Label,
                tag.OwnerId
            );
        }

        // Reading methods --------------------------------------------------
        public async Task<Result<TagResponse>> GetTagAsync(int tagId, int userId)
        {
            var tag = await _tagRepo.GetTagAsync(tagId, userId);

            if (tag == null)
                return Result<TagResponse>.Failure("Tag was not found.", enErrorType.NotFound);

            return Result<TagResponse>.Success(MapTagToTagResponse(tag));
        }

        public async Task<Result<IEnumerable<TagResponse>>> GetTagsByUserIdAsync(int userId)
        {
            var tagsList = await _tagRepo.GetTagsByUserIdAsync(userId);

            if (!tagsList.Any())
                return Result<IEnumerable<TagResponse>>.Success(Enumerable.Empty<TagResponse>());

            var tagsResponse = tagsList.Select(item => MapTagToTagResponse(item)).ToList();

            return Result<IEnumerable<TagResponse>>.Success(tagsResponse);
        }

        // Writing methods --------------------------------------------------
        public async Task<Result<TagResponse>> AddTagAsync(TagDTO tagDto)
        {
            // 1 - Input validations --------------------------------------------
            if (string.IsNullOrWhiteSpace(tagDto.Label))
                return Result<TagResponse>.Failure("Tag label cannot be empty.", enErrorType.Validation);

            tagDto.Id = -1; // Make sure to send -1 to database (safe practice)

            // 2 - Map data ------------------------------------------------------
            var newTag = MapTagDTOtoTagObject(tagDto);

            int newTagId = await _tagRepo.AddTagAsync(newTag);

            if (newTagId == -1)
                return Result<TagResponse>.Failure("Failed to add the tag to the database.", enErrorType.Failure);

            // Re-assign database generated ID to update our local reference object
            var updatedTagWithId = new Tag(newTagId, newTag.OwnerId, newTag.Label);

            // 3 - Form the response ----------------------------------------------
            return Result<TagResponse>.Success(MapTagToTagResponse(updatedTagWithId));
        }

        public async Task<Result<TagResponse>> UpdateTagAsync(TagDTO tagDto)
        {
            // 1 - Input validations --------------------------------------------
            if (string.IsNullOrWhiteSpace(tagDto.Label))
                return Result<TagResponse>.Failure("Tag label cannot be empty.", enErrorType.Validation);

            // 2 - Map data ------------------------------------------------------
            var updatedTag = MapTagDTOtoTagObject(tagDto);

            if (!await _tagRepo.UpdateTagAsync(updatedTag))
                return Result<TagResponse>.Failure("Failed to update the tag in the database.", enErrorType.Failure);

            // 3 - Form the response ----------------------------------------------
            return Result<TagResponse>.Success(MapTagToTagResponse(updatedTag));
        }

        public async Task<Result> DeleteTagAsync(int tagId, int userId)
        {
            if (await _tagRepo.DeleteTagAsync(tagId, userId))
                return Result.Success();

            return Result.Failure("Failed to delete the tag from the database.", enErrorType.Failure);
        }
    }
}