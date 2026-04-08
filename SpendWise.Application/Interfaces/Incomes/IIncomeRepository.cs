using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Incomes
{
    public interface IIncomeRepository
    {
        // Writing to database
        public Task<int> AddIncomeAsync(Income newIncome, Transaction newTransaction);
        public Task<int> UpdateIncomeAsync(Income newIncome, Transaction newTransaction);
        public Task<bool> DeleteIncomeAsync(int incomeId);

        // Reading from the database
        public Task<Transaction> GetIncomeAsync(int incomeId); // returns a transaction to store the full information
        Task<(IEnumerable<Transaction> projects, int totalCount)> GetIncomeByUserAsync(int userId, int pageNumber, int pageSize);

    }
}
