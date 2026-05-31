using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class SharedDebt
    {
        public int DebtID { get; set; }
        public int CreditorID { get; set; }
        public int DebtorID { get; set; }
        public decimal Amount { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty; 
        public DateTime CreatedAt { get; set; }           
        public DateTime DueDate { get; set; }
        public int CreditorWalletID { get; set; }
        public int DebtorWalletID { get; set; }

        public SharedDebt(int debtID, int creditorID, int debtorID, decimal amount, string title, string status, DateTime createdAt, DateTime dueDate, int creditorWalletID, int debtorWalletID)
        {
            DebtID = debtID;
            CreditorID = creditorID;
            DebtorID = debtorID;
            Amount = amount;
            Title = title;
            Status = status;
            CreatedAt = createdAt;
            DueDate = dueDate;
            CreditorWalletID = creditorWalletID;
            DebtorWalletID = debtorWalletID;
        }
    }
}
