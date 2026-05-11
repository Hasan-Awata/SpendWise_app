using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SpendWise.Application.Interfaces
{
    public interface IFixedIncomeRepository
    {
        
      public  Task<FixedIncome> GetFixedIncomeAsync(int fixedIncomeId, int userId);
      public  Task<IEnumerable<FixedIncome?>> GetFixedIncomesByUserIdAsync(int userId);
      
      public  Task<int> CreateFixedIncomeAsync(FixedIncome fixedIncome);
      public  Task<bool> UpdateFixedIncomeAsync(FixedIncome fixedIncome);
      public  Task<bool> DeleteFixedIncomeAsync(int fixedIncomeId, int userId);
      public  Task<bool> IsIncomeActive(int fixedIncomeId);
    }
}