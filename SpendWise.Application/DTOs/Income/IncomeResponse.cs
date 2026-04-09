using SpendWise.Application.DTOs.Tag;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Income
{
    public class IncomeResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public TagResponse? IncomeTag { get; set; }
    }
}
