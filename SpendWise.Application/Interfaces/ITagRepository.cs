using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    public interface ITagRepository
    {
        // Readging from the DB methods
        public Task<Tag> GetTagAsync(int id);
        public Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int UserId);
        public Task<IEnumerable<Tag?>> GetTagsByCategoryIdAsync(int UserId, int CategoryId);

        // Writing to DB methods
        public Task<bool> AddTagAsync(Tag tag);
        public Task<bool> UpdateTagAsync(Tag tag);
        public Task<bool> DeleteTagAsync(int tagId);
    }
}
