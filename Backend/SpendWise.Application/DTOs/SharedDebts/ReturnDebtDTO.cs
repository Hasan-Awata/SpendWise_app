using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.SharedDebts
{
    public class ReturnDebtDTO
    {
        public SharedDebtDTO DebtDTO { get; set; }
        public decimal Amount { get; set; } = 0;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}
