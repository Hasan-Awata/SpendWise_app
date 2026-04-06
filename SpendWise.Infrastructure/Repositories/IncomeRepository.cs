using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Infrastructure.Repositories
{
    public class IncomeRepository : IIncomeRepository
    {
        public Task<bool> AddIncomeAsync(Income income)
        {
            throw new NotImplementedException();
        }

        public Task<bool> DeleteIncomeAsync(int IncomeId, int UserID)
        {
            throw new NotImplementedException();
        }

        public Task<Income> GetIncomeAsync(int userId, int incomeId)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Income?>> GetIncomesByUserIdAsync(int userId)
        {
            throw new NotImplementedException();
        }

        public Task<bool> UpdateIncomeAsync(Income income)
        {
            throw new NotImplementedException();
        }
    }
}
