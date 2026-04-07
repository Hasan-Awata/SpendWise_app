using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Income
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int TagId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public Currency Currency { get; set; } = new Currency(1, "Syrian Pound"); 
        public bool IsMonthly {  get; set; }
        public int Days {  get; set; }
        public DateTime? LastTime { get; set; }
    }
}
