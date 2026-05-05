using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;
using SpendWise.Domain.Enums;

namespace SpendWise.Application.DTOs.Transaction
{
    public class TransactionsDTO
    {
        [Required(ErrorMessage = "Provide the id of the transaction you want to accuire")]
        public int TransactionId { get; set; } = -1;

        [Required(ErrorMessage = "Please enter the transaction type to proceed")]
        public enTransactionType TransactionType { get; set; } // Addetion = 0, Dedduction = 1.
    }
}
