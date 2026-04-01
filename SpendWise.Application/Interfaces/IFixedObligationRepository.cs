using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    public interface IFixedObligationRepository
    {
        // Reading from DB methods
        public Task<FixedObligation> GetFixedObligationAsync(int obligationId);
        public Task<IEnumerable<FixedObligation?>> GetFixedObligationsByUserIdAsync(int userId);

        // Writing to DB methods
        public Task CreateFixedObligationAsync(FixedObligation fixedObligationDTO);
        public Task UpdateFixedObligationAsync(FixedObligation fixedObligationDTO);
        public Task DeleteFixedObligationAsync(int obligationId);
    }
}
