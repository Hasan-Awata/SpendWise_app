using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Income
{
    public class IncomeResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public bool IsFixed { get; set; }
        public bool IsMonthly { get; set; }
        public Currency Currency { get; set; } = new Currency(-1, "Syrain Pound");
        public DateTime? LastTime { get; set; }
    }
}
