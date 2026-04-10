using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Category
{
    public  class CategoryDTO
    {
            public int CategoryId { get; set; }=-1;

            [Required(ErrorMessage = "Category name is required!")]
            [StringLength(100, ErrorMessage = "Name cannot exceed 100 characters.")]
            public string Name { get; set; } = string.Empty;

            [Range(1, 4, ErrorMessage = "Priority must be between 1 and 4!")]
            public int Priority { get; set; }
    }
}
