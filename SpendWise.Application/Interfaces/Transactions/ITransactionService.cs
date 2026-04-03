using SpendWise.Application.DTOs.Transaction;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Transactions
{
    public interface ITransactionService
    {
        public Task<bool> TransactionProcess(TransactionsDTO transactionDto);
        public Task<bool> CreateTransactionAsync(TransactionsDTO transactionDto);

        public Task<bool> UpdateTransactionAsync(TransactionsDTO transactionDto);

        public Task<bool> DeleteTransactionAsync(TransactionsDTO transactionDto);
    }
}
