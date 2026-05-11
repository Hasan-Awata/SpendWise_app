using SpendWise.Application.DTOs.FixedIncome;
using SpendWise.Application.Interfaces;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SpendWise.Application.Services
{
    public class FixedIncomeService : IFixedIncomeService
    {
        private readonly IFixedIncomeRepository _fixedIncomeRepo;

        public FixedIncomeService(IFixedIncomeRepository fixedIncomeRepo)
        {
            _fixedIncomeRepo = fixedIncomeRepo;
        }

        public async Task<FixedIncomeResponse> GetFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            var fixedIncome = await _fixedIncomeRepo.GetFixedIncomeAsync(fixedIncomeId, userId);

            if (fixedIncome == null) return null!;

            return new FixedIncomeResponse
            {
                FixedIncomeId = fixedIncome.FixedIncomeId,
                UserId = fixedIncome.UserId,
                TagId = fixedIncome.TagId,
                Title = fixedIncome.Title,
                Amount = fixedIncome.Amount,
                IsMonthly = fixedIncome.IsMonthly,
                IsActive = fixedIncome.IsActive,
                Days = fixedIncome.Days,
                LastTime = fixedIncome.LastTime
            };
        }

        public async Task<IEnumerable<FixedIncomeResponse>> GetFixedIncomesByUserIdAsync(int userId)
        {
            var fixedIncomesList = await _fixedIncomeRepo.GetFixedIncomesByUserIdAsync(userId);

            // Mapping the entity collection to the response DTO collection
            return fixedIncomesList.Select(item => new FixedIncomeResponse
            {
                FixedIncomeId = item.FixedIncomeId,
                UserId = item.UserId,
                TagId = item.TagId,
                Title = item.Title,
                Amount = item.Amount,
                IsMonthly = item.IsMonthly,
                IsActive = item.IsActive,
                Days = item.Days,
                LastTime = item.LastTime
            });
        }

        public async Task<int> CreateFixedIncomeAsync(FixedIncomeDTO fixedIncomeDTO)
        {
            var newIncome = new FixedIncome(
                fixedIncomeDTO.FixedIncomeId,
                fixedIncomeDTO.UserId,
                fixedIncomeDTO.TagId,
                fixedIncomeDTO.Title,
                fixedIncomeDTO.Amount,
                fixedIncomeDTO.IsMonthly,
                fixedIncomeDTO.IsActive,
                fixedIncomeDTO.Days,
                fixedIncomeDTO.LastTime
            );

          return   await _fixedIncomeRepo.CreateFixedIncomeAsync(newIncome);
        }

        public async Task<bool> UpdateFixedIncomeAsync(FixedIncomeDTO fixedIncomeDTO)
        {
            var updatedIncome = new FixedIncome(
                fixedIncomeDTO.FixedIncomeId,
                fixedIncomeDTO.UserId,
                fixedIncomeDTO.TagId,
                fixedIncomeDTO.Title,
                fixedIncomeDTO.Amount,
                fixedIncomeDTO.IsMonthly,
                fixedIncomeDTO.IsActive,
                fixedIncomeDTO.Days,
                fixedIncomeDTO.LastTime
            );

           return await _fixedIncomeRepo.UpdateFixedIncomeAsync(updatedIncome);
        }

        public async Task <bool>DeleteFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            return     await _fixedIncomeRepo.DeleteFixedIncomeAsync(fixedIncomeId, userId);
        }
        public async Task<bool> IsFixedIncomeActive(int fixedIncomeId) { 
          return await _fixedIncomeRepo.IsIncomeActive(fixedIncomeId);
        
        }

    }
}