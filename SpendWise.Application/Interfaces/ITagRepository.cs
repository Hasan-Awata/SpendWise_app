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
        public Task<Tags> GetTagAsync(int id);
        public Task<IEnumerable<Tags?>> GetTagsByUserIdAsync(int UserId);
        public Task<IEnumerable<Tags?>> GetTagsByCategoryIdAsync(int UserId, int CategoryId);

        // Writing to DB methods
        public Task CreateTagAsync(Tags tag);
        public Task UpdateTagAsync(Tags tag);
        public Task DeleteTagAsync(int tagId);
    }
}
