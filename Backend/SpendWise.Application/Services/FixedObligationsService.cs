using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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

        public async Task<FixedObligationResponse?> GetFixedObligationAsync(int fixedObligationId, int userId)
        {
            if (fixedObligationId <= 0)
                return null;

            if (userId <= 0)
                return null;

            var fixedObligation = await _fixedObligationRepo.GetFixedObligationAsync(fixedObligationId, userId);

            if (fixedObligation == null)
                return null;

            return new FixedObligationResponse
            {
                Id = fixedObligation.Id,
                OwnerId = fixedObligation.OwnerId,
                Title = fixedObligation.Title,
                Amount = fixedObligation.Amount,
                DueDate = fixedObligation.DueDate,
                IsActive = fixedObligation.IsActive,
            };
        }

        public async Task<IEnumerable<FixedObligationResponse>> GetFixedObligationsByUserIdAsync(int userId)
        {
            if (userId <= 0)
                return Enumerable.Empty<FixedObligationResponse>().ToList();

            var fixedObligationsList = await _fixedObligationRepo.GetFixedObligationsByUserIdAsync(userId);

            return fixedObligationsList.Select(item => new FixedObligationResponse
            {
                Id = item.Id,
                OwnerId = item.OwnerId,
                Title = item.Title,
                Amount = item.Amount,
                DueDate = item.DueDate,
                IsActive = item.IsActive,
            }).ToList();
        }

        public async Task<int> CreateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            var newObligation = new FixedObligation(
                fixedObligationDto.Id,
                fixedObligationDto.OwnerId,
                fixedObligationDto.Title,
                fixedObligationDto.Amount,
                fixedObligationDto.DueDate,
                fixedObligationDto.IsActive
            );

            return await _fixedObligationRepo.CreateFixedObligationAsync(newObligation);
        }

        public async Task<bool> UpdateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            var updatedObligation = new FixedObligation(
                fixedObligationDto.Id,
                fixedObligationDto.OwnerId,
                fixedObligationDto.Title,
                fixedObligationDto.Amount,
                fixedObligationDto.DueDate,
                fixedObligationDto.IsActive
            );

            return await _fixedObligationRepo.UpdateFixedObligationAsync(updatedObligation);
        }

        public async Task<bool> DeleteFixedObligationAsync(int fixedObligationId, int userId)
        {
            if (fixedObligationId <= 0)
                return false;

            if (userId <= 0)
                return false;

            return await _fixedObligationRepo.DeleteFixedObligationAsync(fixedObligationId, userId);
        }

        public async Task<bool> IsFixedObligationActive(int fixedObligationId, int userId)
        {
            if (fixedObligationId <= 0)
                return false;

            if (userId <= 0)
                return false;

            return await _fixedObligationRepo.IsObligationActive(fixedObligationId, userId);
        }
    }
}