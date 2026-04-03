using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;
using SpendWise.Domain.Enums;
using SpendWise.Application.DTOs.Income;

namespace SpendWise.Application.DTOs.Transaction
{
    public class TransactionsDTO
    {
        // Required attributes

        [Required(ErrorMessage = "User ID is required to associate the transaction!")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Please enter the transaction amount!")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero!")]
        public decimal Amount { get; set; }

        [Required(ErrorMessage = "Please select a transaction date!")]
        public DateTime TransactionDate { get; set; } = DateTime.Now;

        [Required(ErrorMessage = "Please provide the transaction type")]
        public enTransactionType TransactionType { get; set; }

        // Not required
        [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters!")]
        public string Description { get; set; } = string.Empty;

        // Transaction types DTOs
        public IncomeDTO? IncomeDTO;

        // Record ID and Title are fetched in service layer (Business) during the creation of the transaction
    }
}
