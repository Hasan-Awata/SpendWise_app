using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.DTOs.Wallet;
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
        public WalletResponse Wallet { get; set; } = new WalletResponse();
        public TagResponse? IncomeTag { get; set; }
    }
}
