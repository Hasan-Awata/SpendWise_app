using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.ProcessingResults
{
    public class OcrResult
    {
        public string RawText { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public List<Product> Products { get; set; } = new();
        public decimal Subtotal { get; set; } = decimal.Zero;
        public decimal Tax {  get; set; } = decimal.Zero;
        public decimal Total { get; set; } = decimal.Zero;
        public int CategoryId { get; set; }
        public DateTime Date { get; set; } = DateTime.Now;
        public bool IsSuccess { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
