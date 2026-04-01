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

        public async Task AddTag(TagDTO tagDto)
        {
            var newTag = new Tag(tagDto.Id, tagDto.CategoryId, tagDto.OwnerId, tagDto.Label);

            await _tagRepo.AddTagAsync(newTag);
        }
        public async Task UpdateTag(TagDTO tagDto)
        {
            var updatedTag = new Tag(tagDto.Id, tagDto.CategoryId, tagDto.OwnerId, tagDto.Label);

            await _tagRepo.UpdateTagAsync(updatedTag);
        }
        public async Task DeleteTag(int tagId)
        {
            await _tagRepo.DeleteTagAsync(tagId);
        }
    }
}
