using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Tags
{
    public interface ITagRepository
    {
        // Readging from the DB methods
        public Task<Tag> GetTagAsync(int userId, int tagId);
        public Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int userId);
        public Task<IEnumerable<Tag?>> GetTagsByCategoryIdAsync(int userId, int categoryId);

        // Writing to DB methods
        public Task<bool> AddTagAsync(Tag tag);
        public Task<bool> UpdateTagAsync(Tag tag);
        public Task<bool> DeleteTagAsync(int tagId, int UserID);
    }
}
