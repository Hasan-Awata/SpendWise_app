using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Transaction;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Transactions
{
    public interface ITransactionService
    {
        public Task<PagedResponse<TransactionResponse>> GetTransactionsByUserAsync(int userId, PageDTO pageDto);

    }
}
