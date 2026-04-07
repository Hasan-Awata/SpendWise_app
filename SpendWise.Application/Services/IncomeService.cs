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

        public async Task<IncomeResponse?> GetIncomeAsync(int userId, int incomeId)
        {

            Income? incomeTest = null;

            // incomeTest = await _incomeRepo.GetIncomeAsync(userId, incomeId);

            var incomeResponse = new IncomeResponse
            {
                Id = incomeTest.Id,
                Title = incomeTest.Title,
                Amount = incomeTest.Amount,
                Currency = incomeTest.Currency,
                IsMonthly = incomeTest.IsMonthly,
                LastTime = incomeTest.LastTime,
            };

            return incomeResponse;
        }

        
        public async Task<IEnumerable<IncomeResponse?>> GetIncomesByUserIdAsync(int userId)
        {
            IEnumerable<Income?> incomesList = new List<Income>();
            // incomesList=await _incomeRepo.GetAllByUserId(userId);

            return incomesList.Select(item => new IncomeResponse
            {
                Id = item.Id,
                UserId = item.UserId,
                Title = item.Title,
                Amount = item.Amount,
                Currency = item.Currency,
                IsMonthly = item.IsMonthly,
                LastTime = item.LastTime,
            });

        }


        public async Task<IEnumerable<IncomeResponse?>> GetIncomesByTypeAsync(int userId, int CurrencyId, bool IsFixed)
        {
            IEnumerable<Income?> incomesByType = new List<Income>();

            //incomesByType = await _incomeRepo.GetIncomesByTypeAsync(userId, incomeType);

            return incomesByType.Select(item => new IncomeResponse
            {
                Id = item.Id,
                UserId = item.UserId,
                Title = item.Title,
                Amount = item.Amount,
                Currency = item.Currency,
                IsMonthly = item.IsMonthly,
                LastTime = item.LastTime,
            });
        }

        
        public async Task<bool> AddIncomeAsync(IncomeDTO incomeDto)
        {
           bool isDone = false;

            var income = new Income
            {
                UserId= incomeDto.UserId,
                Title= incomeDto.Title,
                Amount= incomeDto.Amount,
                //Currency= await _currencyRepo.GetCurrencyAsync(incomeDto.CurrencyId),
                IsMonthly= incomeDto.IsMonthly,
                LastTime= incomeDto.LastTime,
            };

            //isDone =await _incomeRepo.AddIncomeAsync(income);

            return isDone;
        }

      
        public async Task<bool> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            bool isDone = false;

            var incomeToUpdate = new Income
            {
                UserId = incomeDto.UserId,
                Title = incomeDto.Title,
                Amount = incomeDto.Amount,
                //Currency= await _currencyRepo.GetCurrencyAsync(incomeDto.CurrencyId),
                IsMonthly = incomeDto.IsMonthly,
                LastTime = incomeDto.LastTime,
            };

            //isDone =await _incomeRepo.UpdateIncomeAsync(incomeToUpdate);

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
