using System.Collections.Generic;
using System.Threading.Tasks;
using EMRSimulation.Domain.Dtos;

namespace EMRSimulation.Infrastructure.Repositories
{
    public interface IPolicyRepository
    {
        Task<IEnumerable<PolicyDto>> GetPoliciesByLabAsync(int labId, string searchTerm);
        Task<PolicyDto> GetPolicyByIdAsync(int id);
        Task SavePolicyAsync(PolicyDto policy);
    }
}
