using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.DTOs.Wallet;
using SpendWise.Domain.Entities;
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
        public int WalletId { get; set; } 
        public int IncomeTagId { get; set; }
        public DateTime Date { get; set; }

        // Transaction Details
        public int TransactionId { get; set; }
        public string Description { get; set; } = string.Empty;
        public decimal AmountInSp { get; set; } = 0.0m;

        public IncomeResponse(SpendWise.Domain.Entities.Income income)
        {
            Id = income.Id;
            UserId = income.UserId;
            Title = income.Title;
            Amount = income.Amount;
            WalletId = income.WalletId;
            Date = income.Date;
            IncomeTagId = income.IncomeTagId;

            TransactionId = income.LinkedTransaction.TransactionId;
            Description = income.LinkedTransaction.Description;
            AmountInSp = income.LinkedTransaction.AmountInSp;
        }

        public IncomeResponse() { }

    }
}
