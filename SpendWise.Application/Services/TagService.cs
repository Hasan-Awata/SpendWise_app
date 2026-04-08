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

        public async Task<TagResponse?> GetTagAsync(int tagId)
        {
            var tag = await _tagRepo.GetTagAsync(tagId);

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

        public async Task AddTagAsync(TagDTO tagDto)
        {
            var newTag = new Tag(tagDto.Id, tagDto.OwnerId, tagDto.Label);

            await _tagRepo.AddTagAsync(newTag);
        }
        public async Task UpdateTagAsync(TagDTO tagDto)
        {
            var updatedTag = new Tag(tagDto.Id, tagDto.OwnerId, tagDto.Label);

            await _tagRepo.UpdateTagAsync(updatedTag);
        }
        public async Task DeleteTagAsync(int tagId)
        {
            await _tagRepo.DeleteTagAsync(tagId);
        }
    }
}
