using SpendWise.Application.Interfaces;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.FixedObligations;

namespace SpendWise.Application.Services
{
    public class FixedObligationsService: IFixedObligationsService
    {
        private readonly IFixedObligationRepository _fixedObligationRepo;

        public FixedObligationsService(IFixedObligationRepository fixedObligationRepo)
        {
            _fixedObligationRepo = fixedObligationRepo;
        }

        public async Task<FixedObligationResponse> GetFixedObligationAsync(int fixedObligationId, int UserID)
        {
            var fixedObligation = await _fixedObligationRepo.GetFixedObligationAsync(fixedObligationId, UserID);
           
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
        public async Task<IEnumerable<FixedObligationResponse?>> GetFixedObligationsByUserIdAsync(int userId)
        {
            var fixedObligationsList = await _fixedObligationRepo.GetFixedObligationsByUserIdAsync(userId);

            // Use LINQ to map each item in the collection
            return fixedObligationsList.Select(item => new FixedObligationResponse
            {
                Id = item.Id,
                OwnerId = item.OwnerId,
                Title = item.Title,
                Amount = item.Amount,
                DueDate = item.DueDate,
                IsActive = item.IsActive,
            });
        }

        public async Task CreateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            var newObligation = new FixedObligation(
                fixedObligationDto.Id,
                fixedObligationDto.OwnerId,
                fixedObligationDto.Title,
                fixedObligationDto.Amount,
                fixedObligationDto.DueDate,
                fixedObligationDto.IsActive
            );

            await _fixedObligationRepo.CreateFixedObligationAsync(newObligation);
        }

        public async Task UpdateFixedObligationAsync(FixedObligationDTO fixedObligationDto)
        {
            var updatedObligation = new FixedObligation(
                fixedObligationDto.Id,
                fixedObligationDto.OwnerId,
                fixedObligationDto.Title,
                fixedObligationDto.Amount,
                fixedObligationDto.DueDate,
                fixedObligationDto.IsActive
            );

            await _fixedObligationRepo.UpdateFixedObligationAsync(updatedObligation);
        }

        public async Task DeleteFixedObligationAsync(int fixedObligationId, int UserID)
        {
            await _fixedObligationRepo.DeleteFixedObligationAsync(fixedObligationId, UserID);
        }

        //private async Task<bool> ValidateAmount(FixedObligationDTO fixedObligationDto)
        //{
        //    /// This method validates the amount of the fixed obligation before saving it to Database
        //    if (fixedObligationDto.Amount)
        //}
    }
}
