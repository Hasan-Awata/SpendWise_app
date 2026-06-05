using SpendWise.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SpendWise.Application.Interfaces.FixedObligations
{
    public interface IFixedObligationRepository
    {
        public Task<FixedObligation?> GetFixedObligationAsync(int obligationId, int userId);

        public Task<IEnumerable<FixedObligation>> GetFixedObligationsByUserIdAsync(int userId);

        public Task<int> CreateFixedObligationAsync(FixedObligation fixedObligation);

        public Task<bool> UpdateFixedObligationAsync(FixedObligation fixedObligation);

        public Task<bool> DeleteFixedObligationAsync(int obligationId, int userId);

        public Task<bool> IsObligationActive(int obligationId, int userId);
    }
}