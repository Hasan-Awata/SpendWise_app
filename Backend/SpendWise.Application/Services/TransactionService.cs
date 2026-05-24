using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Transaction;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;

namespace SpendWise.Application.Services
{
    public class TransactionService: ITransactionService
    {
        private readonly ITransactionRepository _transactionRepo;

        public TransactionService(ITransactionRepository transactionRepo)
        {
            _transactionRepo = transactionRepo;
        }

        public async Task<PagedResponse<TransactionResponse>> GetTransactionsByUserAsync(int userId, PageDTO pageDTO)
        {
            var (transactions, totalCount ) = await _transactionRepo.GetTransactionsByUserAsync(userId, pageDTO.PageNumber, pageDTO.PageSize);

            var transactionResponses = transactions.Select(item => new TransactionResponse(item)).ToList();

            return new PagedResponse<TransactionResponse>(transactionResponses, pageDTO.PageNumber, pageDTO.PageSize, totalCount);
        }
    }
}
