using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Tags
{
    public interface ITagService
    {
        public Task<Tag?> GetTagAsync(int userId, int tagId);
        public Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int UserId);
        public Task<IEnumerable<Tag?>> GetTagsByCategoryIdAsync(int UserId, int CategoryId);

        public Task AddTagAsync(TagDTO tag);
        public Task UpdateTagAsync(TagDTO tag);
        public Task DeleteTagAsync(int userId, int tagId);
    }
}
