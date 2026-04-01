using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    public interface IFixedObligationsService
    {
        // Reading from DB methods
        public Task<FixedObligation> GetFixedObligationAsync(int obligationId);
        public Task<IEnumerable<FixedObligation?>> GetFixedObligationsByUserIdAsync(int userId);

        // Writing to DB methods
        public Task CreateFixedObligationAsync(FixedObligationDTO fixedObligationDTO);
        public Task UpdateFixedObligationAsync(FixedObligationDTO fixedObligationDTO);
        public Task DeleteFixedObligationAsync(int obligationId);

        // Logic methods
        //public Task<bool> ValidateAmount(decimal amount);

    }
}
