using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.SharedDebts
{
    public class SharedDebtResponse
    {
        public int DebtID { get; set; }
        public int CreditorID { get; set; }
        public int DebtorID { get; set; }
        public decimal Amount { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty; // Added
        public DateTime CreatedAt { get; set; }            // Added
        public DateTime DueDate { get; set; }
        public int CreditorWalletID { get; set; } // Added
        public int DebtorWalletID { get; set; } // Added
        public decimal PaidAmount { get; set; } // Added

        public SharedDebtResponse(SpendWise.Domain.Entities.SharedDebt debt)
        {
            this.DebtID = debt.DebtID;
            this.CreditorID = debt.CreditorID;
            this.DebtorID = debt.DebtorID;
            this.Amount = debt.Amount;
            this.Title = debt.Title;
            this.Status = debt.Status;
            this.CreatedAt = debt.CreatedAt;
            this.DueDate = debt.DueDate;
            this.CreditorWalletID = debt.CreditorWalletID;
            this.DebtorWalletID = debt.DebtorWalletID;
            this.PaidAmount = debt.PaidAmount;
        }
     
    }
}
