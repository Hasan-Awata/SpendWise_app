using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Category
{
    public class CategoryResponse
    {
        public int CategoryId { get; set; } = -1;
        public string Name { get; set; } = string.Empty;
        public int Priority { get; set; }
        public CategoryResponse() { }

        public CategoryResponse(Domain.Entities.Category category) { 
        CategoryId = category.CategoryId;
            Name = category.Name;
            Priority = category.Priority;

        
        }
    }
}
