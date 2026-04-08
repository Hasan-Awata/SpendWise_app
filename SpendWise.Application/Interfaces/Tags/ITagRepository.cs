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
        public Task<Tag> GetTagAsync(int tagId, int userId);
        public Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int userId);

        // Writing to DB methods
        public Task<int> AddTagAsync(Tag tag);
        public Task<bool> UpdateTagAsync(Tag tag);
        public Task<bool> DeleteTagAsync(int tagId);
    }
}
