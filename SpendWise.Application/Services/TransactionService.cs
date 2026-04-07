using SpendWise.Application.DTOs.Transaction;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;

namespace SpendWise.Application.Services
{
    public class TransactionService : ITransactionService
    {
        private readonly ITransactionService _transactionService;

        public TransactionService(ITransactionService transactionService)
        {
            _transactionService = transactionService;
        }
    }
}
