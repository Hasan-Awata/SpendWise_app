using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
  public  enum enTransactionMode { AddNew =1,Update =2}
    public enum enTransactionType { MoneyEntry =1 }
    public class Transaction
    {

        public int TransactionId { get; set; } = -1;
        public int UserId { get; set; } = -1;
        public int? SharedDebtId { get; set; } = -1; 
        public SharedDepts? SharedDepts { get; set; }

        public int? TagId { get; set; } = -1;
        public Tag? Tag { get; set; }
        
        public int? GoalId { get; set; } = -1;
        //A "saving goals" object must be added.

        public int? ObligationId { get; set; } = -1;
        public decimal Amount { get; set; } = 0.0m;
        public DateTime TransactionDate { get; set; } = DateTime.Now;
       
        public string Description { get; set; } = string.Empty;
        public enTransactionType TransactionType { get; set; }
         private enTransactionMode TransactionMode { get; set; }


        private Transaction(int transactionId, int userId, int? debtId, int? tagId, int? goalId, int? obligationId, decimal amount, DateTime transactionDate, string description)
        {
            TransactionId = transactionId;
            UserId = userId;
            SharedDebtId = debtId;
            TagId = tagId;
            GoalId = goalId;
            ObligationId = obligationId;
            Amount = amount;
            TransactionDate = transactionDate;
           
            Description = description;
            TransactionMode = enTransactionMode.AddNew;

            
        }
        public Transaction( int userId, int? debtId, int? tagId, int? goalId, int? obligationId, decimal amount, DateTime transactionDate,  string description)
        {
          
            UserId = userId;
            SharedDebtId = debtId;
            TagId = tagId;
            GoalId = goalId;
            ObligationId = obligationId;
            Amount = amount;
            TransactionDate = transactionDate;
         
            Description = description;
            TransactionMode= enTransactionMode.Update;
        }

    }
}
