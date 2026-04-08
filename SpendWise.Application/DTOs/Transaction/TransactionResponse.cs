using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Transaction
{
    public class TransactionResponse
    {
        public int TransactionId { get; set; } = -1;
        public int UserId { get; set; } = -1;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int? TagId { get; set; }
        public decimal Amount { get; set; }
        public DateTime TransactionDate { get; set; } = DateTime.Now;
        
        public enTransactionMode TransactionMode { get; set; }
        //Add = 0,
        //Edit = 1,
        //Delete = 2,
        public enTransactionType TransactionType { get; set; }
        //Income              // A revenue provided for once to do a specific service e.g(freelancer, trader, ...) or a Salary
        //FixedObligation     // A fixed amount of money a person have to pay every due date, e.g(rent, suscription, ...)
        //SavingGoal          // A wish list item a person wants to save money to buy
        //Expense             // A transaction indicates that the user has payed for something
    }
}
