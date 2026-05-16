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
        public Task<FixedObligation> GetFixedObligationAsync(int obligationId, int UserID);
        public Task<IEnumerable<FixedObligation?>> GetFixedObligationsByUserIdAsync(int userId);

        // Writing to DB methods
        public Task<bool> CreateFixedObligationAsync(FixedObligation fixedObligation);
        public Task<bool> UpdateFixedObligationAsync(FixedObligation fixedObligation);
        public Task<bool> DeleteFixedObligationAsync(int obligationId, int UserID);
    }
}
