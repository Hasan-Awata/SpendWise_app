using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Transactions
{
    public interface ITransactionRepository
    {
        // Backwards compatible signature with optional filters
        public Task<(IEnumerable<Transaction> transactions, int totalCount)> GetTransactionsByUserAsync(int userId, int pageNumber, int pageSize, int? tagId = null, int? categoryId = null, int? transactionType = null);

    }
}
