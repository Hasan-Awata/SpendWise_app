using SpendWise.Application.DTOs.FixedIncome;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SpendWise.Application.Interfaces
{
    public interface IFixedIncomeService
    {

    public     Task<FixedIncomeResponse?> GetFixedIncomeAsync(int fixedIncomeId, int userId);
        public Task<IEnumerable<FixedIncomeResponse>> GetFixedIncomesByUserIdAsync(int userId);

       
       public Task <int>CreateFixedIncomeAsync(FixedIncomeDTO fixedIncomeDTO);
         public Task<bool> UpdateFixedIncomeAsync(int fixedIncomeId,FixedIncomeDTO fixedIncomeDTO);
       public Task<bool> DeleteFixedIncomeAsync(int fixedIncomeId, int userId);

     
       public  Task<bool> IsFixedIncomeActive(int fixedIncomeId,int userId);
    }
}