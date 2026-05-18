using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Transactions
{
    public interface ITransactionRepository
    {
        public Task<(IEnumerable<Transaction> transactions, int totalCount)> GetTransactionsByUserAsync(int userId, int pageNumber, int pageSize);

    }
}
