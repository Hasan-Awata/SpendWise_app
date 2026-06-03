using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Transaction;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Domain.Common;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SpendWise.Application.Services
{
    public class TransactionService : ITransactionService
    {
        private readonly ITransactionRepository _transactionRepo;

        public TransactionService(ITransactionRepository transactionRepo)
        {
            _transactionRepo = transactionRepo;
        }

        public async Task<Result<PagedResponse<TransactionResponse>>> GetTransactionsByUserAsync(int userId, PageDTO pageDTO)
        {
            // Defensive Identity Guard
            if (userId <= 0)
            {
                return Result<PagedResponse<TransactionResponse>>.Failure("Invalid user identity correlation.", enErrorType.Validation);
            }

            // Defensive Pagination Guard
            if (pageDTO == null)
            {
                return Result<PagedResponse<TransactionResponse>>.Failure("Pagination configuration parameters cannot be null.", enErrorType.Validation);
            }

            var (transactions, totalCount) = await _transactionRepo.GetTransactionsByUserAsync(userId, pageDTO.PageNumber, pageDTO.PageSize);

            // Handle Empty Dataset Smoothly without throwing downstream errors
            if (transactions == null || !transactions.Any())
            {
                var emptyResponse = new PagedResponse<TransactionResponse>(new List<TransactionResponse>(), pageDTO.PageNumber, pageDTO.PageSize, 0);
                return Result<PagedResponse<TransactionResponse>>.Success(emptyResponse);
            }

            var transactionResponses = transactions.Select(item => new TransactionResponse(item)).ToList();
            var pagedResponse = new PagedResponse<TransactionResponse>(transactionResponses, pageDTO.PageNumber, pageDTO.PageSize, totalCount);

            return Result<PagedResponse<TransactionResponse>>.Success(pagedResponse);
        }
    }
}