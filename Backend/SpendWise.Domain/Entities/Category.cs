using SpendWise.Domain.Enums;
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
        public Category(int  categoryId, string name, int priority)
        {
            CategoryId = categoryId;
            Name = name;
            Priority = priority;
        }
        public Category() { }
        // 1 - Highest priority: Essentials
        // 2 - medium priority: Secondaries
        // 3 - lowest priority: Luxuries
        // 4 - Savings
    }

}
