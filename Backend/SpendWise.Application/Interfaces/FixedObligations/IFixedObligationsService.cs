using SpendWise.Application.DTOs.FixedObligations;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SpendWise.Application.Interfaces.FixedObligations
{
    public interface IFixedObligationsService
    {
        public Task<FixedObligationResponse?> GetFixedObligationAsync(int fixedObligationId, int userId);

        public Task<IEnumerable<FixedObligationResponse>> GetFixedObligationsByUserIdAsync(int userId);

        public Task<int> CreateFixedObligationAsync(FixedObligationDTO fixedObligationDto);

        public Task<bool> UpdateFixedObligationAsync(int fixedObligationId,FixedObligationDTO fixedObligationDto);

        public Task<bool> DeleteFixedObligationAsync(int fixedObligationId, int userId);

        public Task<bool> IsFixedObligationActive(int fixedObligationId, int userId);
    }
}