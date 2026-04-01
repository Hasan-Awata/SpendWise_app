using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;
using System.Transactions;

namespace SpendWise.Application.DTOs
{
    public enum enTransactionType { MoneyEntry = 1 }
    public class TransactionsDTO
    {

        [Required(ErrorMessage = "Transaction ID is required!")]
        public int TransactionId { get; set; }

        [Required(ErrorMessage = "User ID is required to associate the transaction!")]
        public int UserId { get; set; }

        // هذه الحقول اختيارية (Nullable) في قاعدة البيانات، لذا لا نضع لها [Required]
        public int? DebtId { get; set; }
        public int? TagId { get; set; }
        public int? GoalId { get; set; }
        public int? ObligationId { get; set; }

        [Required(ErrorMessage = "Please enter the transaction amount!")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }

        [Required(ErrorMessage = "Please select a transaction date!")]
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters!")]
        public string Description { get; set; } = string.Empty;
        public enTransactionType TransactionType { get; set; }
    }
}
