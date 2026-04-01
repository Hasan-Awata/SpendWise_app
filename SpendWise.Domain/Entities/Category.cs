using System;
using System.Collections.Generic;
using System.Reflection.Emit;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Category
    {
        public int CategoryId { get; private set; }
        public string Name { get; private set; } = string.Empty;
        public int Priority { get; private set; }

    }
}
