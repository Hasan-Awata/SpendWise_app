using System;
using System.Collections.Generic;
using System.Reflection.Emit;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Category
    {
            public int CategoryId { get; set; }
            public string Name { get; set; } = string.Empty;
            public int Priority { get; set; }

            // Budget properties merged into Category
            public decimal LimitAmount { get; set; }
            public decimal Percentage { get; set; }

            public int Month { get; set; }
            public int Year { get; set; }

            
       
    }
}
