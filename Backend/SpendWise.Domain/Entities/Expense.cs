using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Expense
    {
        public int ExpenseId { get; set; }
        public int UserId { get; set; }
        public decimal Amount { get; set; }
        public string Products { get; set; } = string.Empty;
        public int ExpenseTagId { get; set; }
        public int CategoryId { get; set; } 
        public int WalletId { get; set; } 
        public DateTime Date { get; set; }

    }
}
