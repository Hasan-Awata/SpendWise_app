using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class SharedDepts
    {
        public int DebtId { get; set; } = -1;
        public int CreditorId { get; set; } = -1;
        public int DebtorId { get; set; } = -1;
        public decimal Amount { get; set; } = 0.0m;
        public string Description { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? DueDate { get; set; } = null; 
        public SharedDepts( int creditorId, int debtorId, decimal amount, string description, string status, DateTime createdAt, DateTime? dueDate)
        {
         
            CreditorId = creditorId;
            DebtorId = debtorId;
            Amount = amount;
            Description = description;
            Status = status;
            CreatedAt = createdAt;
            DueDate = dueDate;
        }
    }
}
