using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Category
{
    public  class CategoryDTO
    {
            [Required(ErrorMessage = "Category Id is required!")]
            public int CategoryId { get; set; }=-1;
            [Required(ErrorMessage = "Category name is required!")]
            [StringLength(100, ErrorMessage = "Name cannot exceed 100 characters.")]
            public string Name { get; set; } = string.Empty;

            [Range(1, 5, ErrorMessage = "Priority must be between 1 and 5!")]
            public int Priority { get; set; }

            [Required(ErrorMessage = "Limit amount is required!")]
            [Range(0.01, double.MaxValue, ErrorMessage = "Limit amount must be greater than 0!")]
            public decimal LimitAmount { get; set; }

            [Range(0, 100, ErrorMessage = "Percentage must be between 0 and 100!")]
            public decimal Percentage { get; set; }

            [Range(1, 12, ErrorMessage = "Month must be between 1 and 12!")]
            public int Month { get; set; }

            [Required(ErrorMessage = "Year is required!")]
            public int Year { get; set; }
             

            public enCategoryType categoryType { get; set; }

         
        
    }
}
