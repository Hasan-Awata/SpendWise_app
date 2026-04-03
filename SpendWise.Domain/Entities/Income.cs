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
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public bool IsFixed { get; set; }
        public bool IsMonthly { get; set; }
        public Currency Currency { get; set; } = new Currency(-1, "Syrain Pound");
        public DateTime? LastTime { get; set; } 
    }
}
