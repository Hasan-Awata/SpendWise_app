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
        public Tag? ExpenseTag { get; set; }
        public Category Category { get; set; } = new Category();
        public Wallet Wallet { get; set; } = new Wallet();
        public DateTime Date { get; set; }

    }
}
