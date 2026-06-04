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

        // =========================================================================
        // Centralized Mapping Helpers
        // =========================================================================

        // تمت إضافة fixedIncomeId كبارامتر لأن الـ DTO لم يعد يحتويه
        private FixedIncome MapDTOToIncomeObject(int fixedIncomeId, FixedIncomeDTO dto)
        {
            return new FixedIncome(
                fixedIncomeId,
                dto.UserId,
                dto.WalletId,
                dto.Title,
                dto.Amount,
                dto.IsMonthly,
                dto.IsActive,
                dto.Days,
                dto.LastTime
            );
        }

        private FixedIncomeResponse MapEntityToResponse(FixedIncome entity)
        {
            return new FixedIncomeResponse
            {
                FixedIncomeId = entity.FixedIncomeId,
                UserId = entity.UserId,
                WalletId = entity.WalletId,
                Title = entity.Title,
                Amount = entity.Amount,
                IsMonthly = entity.IsMonthly,
                IsActive = entity.IsActive,
                Days = entity.Days,
                LastTime = entity.LastTime
            };
        }

        // =========================================================================
        // Centralized Validations
        // =========================================================================

        private bool ValidateFixedIncomeDTO(FixedIncomeDTO dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
                return false;

            if (dto.Amount <= 0)
                return false;

            if (dto.UserId < 0 || dto.WalletId < 0)
                return false;

            return true;
        }

        // =========================================================================
        // Reading Methods
        // =========================================================================

        public async Task<FixedIncomeResponse?> GetFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            if (fixedIncomeId <= 0 || userId <= 0)
                return null;

            var fixedIncome = await _fixedIncomeRepo.GetFixedIncomeAsync(fixedIncomeId, userId);

            if (fixedIncome == null)
                return null;

            return MapEntityToResponse(fixedIncome);
        }

        public async Task<IEnumerable<FixedIncomeResponse>> GetFixedIncomesByUserIdAsync(int userId)
        {
            if (userId <= 0)
                return Enumerable.Empty<FixedIncomeResponse>();

            var fixedIncomesList = await _fixedIncomeRepo.GetFixedIncomesByUserIdAsync(userId);

            if (fixedIncomesList == null || !fixedIncomesList.Any())
                return Enumerable.Empty<FixedIncomeResponse>();

            return fixedIncomesList.Select(MapEntityToResponse).ToList();
        }

        public async Task<bool> IsFixedIncomeActive(int fixedIncomeId, int userId)
        {
            if (fixedIncomeId <= 0 || userId <= 0)
                return false;

            return await _fixedIncomeRepo.IsIncomeActive(fixedIncomeId, userId);
        }

        // =========================================================================
        // Writing Methods
        // =========================================================================

        public async Task<int> CreateFixedIncomeAsync(FixedIncomeDTO fixedIncomeDTO)
        {
            if (!ValidateFixedIncomeDTO(fixedIncomeDTO))
                return -1;

            // نمرر -1 لأن هذا سجل جديد لا يملك ID بعد
            var newIncome = MapDTOToIncomeObject(-1, fixedIncomeDTO);

            return await _fixedIncomeRepo.CreateFixedIncomeAsync(newIncome);
        }

        // تم إضافة fixedIncomeId كبارامتر لتحديد السجل المراد تعديله
        public async Task<bool> UpdateFixedIncomeAsync(int fixedIncomeId, FixedIncomeDTO fixedIncomeDTO)
        {
            if (fixedIncomeId <= 0)
                return false;

            if (!ValidateFixedIncomeDTO(fixedIncomeDTO))
                return false;

         var updatedIncome = MapDTOToIncomeObject(fixedIncomeId, fixedIncomeDTO);

            return await _fixedIncomeRepo.UpdateFixedIncomeAsync(updatedIncome);
        }

        public async Task<bool> DeleteFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            if (fixedIncomeId <= 0 || userId <= 0)
                return false;

            return await _fixedIncomeRepo.DeleteFixedIncomeAsync(fixedIncomeId, userId);
        }
    }
}