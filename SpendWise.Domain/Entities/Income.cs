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
        public Wallet Wallet { get; set; } = new Wallet();
        public Tag? IncomeTag { get; set; } = null;
        public Transaction LinkedTransaction { get; set; } = new Transaction();
        public Income(int id, int userId, decimal amount, DateTime date, Wallet wallet, Tag? incomeTag, Transaction linkedTransaction)
        {
            Id = id;
            UserId = userId;
            Amount = amount;
            Date = date;
            Wallet = wallet;
            IncomeTag = incomeTag;
            LinkedTransaction = linkedTransaction;
        }
        public Income() { }
    }
}
