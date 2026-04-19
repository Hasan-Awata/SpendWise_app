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
        public decimal Amount { get; set; }
        public DateTime Date { get; set; } = DateTime.Now;
        public int WalletId { get; set; } 
        public int IncomeTagId { get; set; } 
        public Transaction LinkedTransaction { get; set; } = new Transaction();
    }
}
