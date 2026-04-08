using SpendWise.Application.DTOs.Tag;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Tags
{
    public interface ITagService
    {
        public Task<TagResponse?> GetTagAsync(int tagId, int userId);
        public Task<IEnumerable<TagResponse?>> GetTagsByUserIdAsync(int UserId);

        public Task AddTagAsync(TagDTO tag);
        public Task UpdateTagAsync(TagDTO tag);
        public Task DeleteTagAsync(int tagId);
    }
}
