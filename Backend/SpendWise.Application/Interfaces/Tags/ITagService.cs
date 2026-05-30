using SpendWise.Application.DTOs.Tag;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Domain.Common;
namespace SpendWise.Application.Interfaces.Tags
{
    public interface ITagService
    {
        public Task<Result<TagResponse>> GetTagAsync(int tagId, int userId);
        public Task<Result<IEnumerable<TagResponse>>> GetTagsByUserIdAsync(int UserId);

        public Task<Result<TagResponse>> AddTagAsync(TagDTO tag);
        public Task<Result<TagResponse>> UpdateTagAsync(TagDTO tag);
        public Task<Result> DeleteTagAsync(int tagId, int userId);
    }
}
