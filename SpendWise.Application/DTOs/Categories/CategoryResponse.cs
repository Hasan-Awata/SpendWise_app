using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Categories
{
    public class CategoryResponse
    {
        public int CategoryId { get; private set; }
        public string Name { get; private set; } = string.Empty;
        public int Priority { get; private set; }

    }
}
