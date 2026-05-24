using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Expense
{
    public class ProductDTO
    {
        public string Name { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }
}
