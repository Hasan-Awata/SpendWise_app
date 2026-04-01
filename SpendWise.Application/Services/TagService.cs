using SpendWise.Application.DTOs;
using SpendWise.Application.Interfaces;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    internal class TagService: ITagService
    {
        private readonly ITagRepository _tagRepo;

        public TagService(ITagRepository tagRepository)
        {
            _tagRepo = tagRepository;
        }

        public async Task CreateTag(TagDTO tagDto)
        {
            var newTag = new Tags
            {
                Id = tagDto.Id,
                Label = tagDto.Label,
                OwnerId = tagDto.OwnerId,
                CategoryId = tagDto.CategoryId,
            };

            await _tagRepo.CreateTagAsync(newTag);
        }
        public async Task UpdateTag(TagDTO tagDto)
        {
            var updatedTag = new Tags
            {
                Id = tagDto.Id,
                Label = tagDto.Label,
                OwnerId = tagDto.OwnerId,
                CategoryId = tagDto.CategoryId,
            };

            await _tagRepo.UpdateTagAsync(updatedTag);
        }
        public async Task DeleteTag(int tagId)
        {
            await _tagRepo.DeleteTagAsync(tagId);
        }
    }
}
