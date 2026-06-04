using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SpendWise.Application.DTOs.FixedObligations;
using SpendWise.Application.Interfaces.FixedObligations;

namespace SpendWise.Application.Services
{
    public class FixedObligationsService : IFixedObligationsService
    {
        private readonly IFixedObligationRepository _fixedObligationRepo;

        public FixedObligationsService(IFixedObligationRepository fixedObligationRepo)
        {
            _fixedObligationRepo = fixedObligationRepo;
        }

        // --- Helper Methods ---

        private FixedObligation MapDTOToObligationObject(int fixedObligationId, FixedObligationDTO dto)
        {
            return new FixedObligation(
                fixedObligationId,
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

        private FixedObligationResponse MapEntityToResponse(FixedObligation entity)
        {
            return new FixedObligationResponse
            {
                FixedObligationId = entity.FixedObligationId,
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

        private bool ValidateFixedObligationDTO(FixedObligationDTO dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
                return false;

            if (dto.Amount <= 0)
                return false;

            if (dto.UserId <= 0 || dto.WalletId <= 0)
                return false;

            return true;
        }

        // --- Interface Implementation ---

        public async Task<FixedObligationResponse?> GetFixedObligationAsync(int fixedObligationId, int userId)
        {
            if (fixedObligationId <= 0 || userId <= 0)
                return null;

            var fixedObligation = await _fixedObligationRepo.GetFixedObligationAsync(fixedObligationId, userId);

            if (fixedObligation == null)
                return null;

            return MapEntityToResponse(fixedObligation);
        }

        public async Task<IEnumerable<FixedObligationResponse>> GetFixedObligationsByUserIdAsync(int userId)
        {
            if (userId <= 0)
                return Enumerable.Empty<FixedObligationResponse>();

            var fixedObligationsList = await _fixedObligationRepo.GetFixedObligationsByUserIdAsync(userId);

            if (fixedObligationsList == null || !fixedObligationsList.Any())
                return Enumerable.Empty<FixedObligationResponse>();

            return fixedObligationsList.Select(MapEntityToResponse).ToList();
        }

        public async Task<bool> IsFixedObligationActive(int fixedObligationId, int userId)
        {
            if (fixedObligationId <= 0 || userId <= 0)
                return false;

            return await _fixedObligationRepo.IsObligationActive(fixedObligationId, userId);
        }

        public async Task<int> CreateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            if (!ValidateFixedObligationDTO(fixedObligationDto))
                return -1;

            var newObligation = MapDTOToObligationObject(-1, fixedObligationDto);

            return await _fixedObligationRepo.CreateFixedObligationAsync(newObligation);
        }

        public async Task<bool> UpdateFixedObligationAsync(int fixedObligationId, FixedObligationDTO fixedObligationDto)
        {
            if (fixedObligationId <= 0)
                return false;

            if (!ValidateFixedObligationDTO(fixedObligationDto))
                return false;

            var updatedObligation = MapDTOToObligationObject(fixedObligationId, fixedObligationDto);

            return await _fixedObligationRepo.UpdateFixedObligationAsync(updatedObligation);
        }

        public async Task<bool> DeleteFixedObligationAsync(int fixedObligationId, int userId)
        {
            if (fixedObligationId <= 0 || userId <= 0)
                return false;

            return await _fixedObligationRepo.DeleteFixedObligationAsync(fixedObligationId, userId);
        }
    }
}