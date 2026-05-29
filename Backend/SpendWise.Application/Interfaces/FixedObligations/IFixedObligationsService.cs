using SpendWise.Application.DTOs.FixedObligations;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.FixedObligations
{
    public interface IFixedObligationsService
    {
        // Reading from DB methods
        public Task<FixedObligationResponse> GetFixedObligationAsync(int obligationId, int UserID);
        public Task<IEnumerable<FixedObligationResponse?>> GetFixedObligationsByUserIdAsync(int userId);

        // Writing to DB methods
        public Task CreateFixedObligationAsync(FixedObligationDTO fixedObligationDTO);
        public Task UpdateFixedObligationAsync(FixedObligationDTO fixedObligationDTO);
        public Task DeleteFixedObligationAsync(int obligationId, int UserID);

        // Logic methods
        //public Task<bool> ValidateAmount(decimal amount);

    }
}
