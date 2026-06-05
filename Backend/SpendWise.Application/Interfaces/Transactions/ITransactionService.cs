using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Transaction;
using SpendWise.Domain.Common;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Transactions
{
    public interface ITransactionService
    {
        public Task<Result<PagedResponse<TransactionResponse>>> GetTransactionsByUserAsync(int userId, PageDTO pageDto);

    }
}
