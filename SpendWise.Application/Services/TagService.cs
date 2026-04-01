using SpendWise.Application.DTOs;
using SpendWise.Application.Interfaces;
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

        public async Task<Tag?> GetTagAsync(int tagId)
        {
            var tag = await _tagRepo.GetTagAsync(tagId);

            return tag;
        }

        public async Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int userId)
        {
            var tagsList = await _tagRepo.GetTagsByUserIdAsync(userId);

            return tagsList;
        }

        public async Task<IEnumerable<Tag?>> GetTagsByCategoryIdAsync(int userId, int categoryId)
        {
            var tagsList = await _tagRepo.GetTagsByCategoryIdAsync(userId, categoryId);

            return tagsList;
        }

        public async Task AddTagAsync(TagDTO tagDto)
        {
            var newTag = new Tag(tagDto.Id, tagDto.CategoryId, tagDto.OwnerId, tagDto.Label);

            await _tagRepo.AddTagAsync(newTag);
        }
        public async Task UpdateTagAsync(TagDTO tagDto)
        {
            var updatedTag = new Tag(tagDto.Id, tagDto.CategoryId, tagDto.OwnerId, tagDto.Label);

            await _tagRepo.UpdateTagAsync(updatedTag);
        }
        public async Task DeleteTagAsync(int tagId)
        {
            await _tagRepo.DeleteTagAsync(tagId);
        }
    }
}
