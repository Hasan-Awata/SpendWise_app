using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    internal interface ITagService
    {
        public Task AddTag(TagDTO tag);
        public Task UpdateTag(TagDTO tag);
        public Task DeleteTag(int tagId);
    }
}
