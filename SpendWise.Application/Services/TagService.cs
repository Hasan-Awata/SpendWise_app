using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class TagService: ITagService
    {
        private readonly ITagRepository _tagRepo;

        public TagService(ITagRepository tagRepository)
        {
            _tagRepo = tagRepository;
        }

        public async Task<TagResponse?> GetTagAsync(int tagId, int userId)
        {
            var tag = await _tagRepo.GetTagAsync(tagId, userId);

            return new TagResponse 
            {
                Id = tag.Id,
                Label = tag.Label,
                OwnerId = tag.OwnerId,
            };
        }

        public async Task<IEnumerable<TagResponse?>> GetTagsByUserIdAsync(int userId)
        {
            var tagsList = await _tagRepo.GetTagsByUserIdAsync(userId);

            return tagsList.Select(item => new TagResponse 
            {
                Id = item.Id,
                Label = item.Label,
                OwnerId = item.OwnerId
            });
        }

        public async Task<TagResponse?> AddTagAsync(TagDTO tagDto)
        {
            var newTag = new Tag(tagDto.Id, tagDto.OwnerId, tagDto.Label);

            int newTagId = await _tagRepo.AddTagAsync(newTag);

            if (newTagId == -1)
            {
                return null;
            }

            return new TagResponse
            {
                Id = newTagId,
                Label = newTag.Label,
                OwnerId = newTag.OwnerId,
            };
        }
        public async Task<TagResponse?> UpdateTagAsync(TagDTO tagDto)
        {
            var updatedTag = new Tag(tagDto.Id, tagDto.OwnerId, tagDto.Label);

            if (!await _tagRepo.UpdateTagAsync(updatedTag))
            {
                return null;
            }

            return new TagResponse
            {
                Id = updatedTag.Id,
                Label = updatedTag.Label,
                OwnerId = updatedTag.OwnerId,
            };

        }
        public async Task DeleteTagAsync(int tagId, int userId)
        {
            await _tagRepo.DeleteTagAsync(tagId, userId);
        }
    }
}
