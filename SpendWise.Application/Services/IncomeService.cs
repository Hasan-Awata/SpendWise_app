using SpendWise.Application.DTOs.Income;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class IncomeService
    {
        //Add Later 
        //private IIncomeRepository readonly _IncomeRepo;

        public async Task<Income?> GetIncomeAsync(int userId, int incomeId)
        {
           
            Income? incomeTest = null;
            
            // incomeTest = await _incomeRepo.GetIncomeAsync(userId, incomeId);
            return incomeTest;
        }

        
        public async Task<IEnumerable<Income?>> GetIncomesByUserIdAsync(int userId)
        {
            IEnumerable<Income?> incomesList = new List<Income>();
            // incomesList=await _incomeRepo.GetAllByUserId(userId);
            return incomesList;

        }

       
        public async Task<IEnumerable<IncomeDTO?>> GetIncomesByTypeAsync(int userId, enIncomeType incomeType)
        {
            IEnumerable<IncomeDTO?> incomesByType = new List<IncomeDTO>();
            //incomesByType = await _incomeRepo.GetIncomesByTypeAsync(userId, incomeType);
            return incomesByType;
        }

        
        public async Task<bool> AddIncomeAsync(IncomeDTO income)
        {
           bool isDone = false;
            //isDone =await _incomeRepo.AddIncomeAsync(income);
            return isDone;
        }

      
        public async Task<bool> UpdateIncomeAsync(IncomeDTO income)
        {
            bool isDone = false;
            //isDone =await _incomeRepo.UpdateIncomeAsync(income);
            return isDone;
        }

       
        public async Task<bool> DeleteIncomeAsync(int incomeId)
        {
            bool isDone = false;
            //isDone =await _incomeRepo.DeleteIncomeAsync(incomeId);
            return isDone;


        }
    }
}
