using SpendWise.Application.Interfaces;
using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class FixedObligationsService: IFixedObligationsService
    {
        private readonly IFixedObligationRepository _fixedObligationRepo;

        public FixedObligationsService(IFixedObligationRepository fixedObligationRepo)
        {
            _fixedObligationRepo = fixedObligationRepo;
        }

        public async Task<FixedObligation> GetFixedObligationAsync(int fixedObligationId)
        {
            return await _fixedObligationRepo.GetFixedObligationAsync(fixedObligationId);
        }
        public async Task<IEnumerable<FixedObligation?>> GetFixedObligationsByUserIdAsync(int userId)
        {
            return await _fixedObligationRepo.GetFixedObligationsByUserIdAsync(userId);
        }

        public async Task CreateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            var newObligation = new FixedObligation 
            {
                Id = fixedObligationDto.Id,
                OwnerId = fixedObligationDto.OwnerId,
                Title = fixedObligationDto.Title,
                Amount = fixedObligationDto.Amount,
                DueDate = fixedObligationDto.DueDate,
                IsActive = fixedObligationDto.IsActive,
            };

            await _fixedObligationRepo.CreateFixedObligationAsync(newObligation);
        }

        public async Task UpdateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            var updatedObligation = new FixedObligation
            {
                Id = fixedObligationDto.Id,
                OwnerId = fixedObligationDto.OwnerId,
                Title = fixedObligationDto.Title,
                Amount = fixedObligationDto.Amount,
                DueDate = fixedObligationDto.DueDate,
                IsActive = fixedObligationDto.IsActive,
            };

            await _fixedObligationRepo.UpdateFixedObligationAsync(updatedObligation);
        }

        public async Task DeleteFixedObligationAsync(int fixedObligationId)
        {
            await _fixedObligationRepo.DeleteFixedObligationAsync(fixedObligationId);
        }
    }
}
