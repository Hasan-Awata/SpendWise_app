using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Domain.Entities;

namespace SpendWise.Application.Interfaces.Incomes
{
    public interface IIncomeRepository
    {
        // Readging from the DB methods
        public Task<Income> GetIncomeAsync(int userId, int incomeId);
        public Task<IEnumerable<Income?>> GetIncomesByUserIdAsync(int userId);

        // Writing to DB methods
        public Task<bool> AddIncomeAsync(Income income);
        public Task<bool> UpdateIncomeAsync(Income income);
        public Task<bool> DeleteIncomeAsync(int IncomeId, int UserID);
    }
}
