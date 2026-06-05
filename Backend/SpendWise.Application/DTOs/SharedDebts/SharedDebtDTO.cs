using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.SharedDebts
{
    public class SharedDebtDTO
    {
        public int CreditorID { get; set; }

        public int DebtorID { get; set; }

        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero.")]
        public decimal Amount { get; set; }

        [Required, StringLength(100, ErrorMessage = "Title cannot exceed 100 characters.")]
        public string Title { get; set; } = string.Empty;

        // Optional: User can set status during creation, or leave it to default "Pending"
        public string Status { get; set; } = "Pending";

        [Required(ErrorMessage = "Due date is required.")]
        public DateTime DueDate { get; set; }
        public DateTime CreatedAt { get; set; }

        public int CreditorWalletID { get; set; }
        public int DebtorWalletID { get; set; }
        public decimal PaidAmount { get; set; }
    }
}
