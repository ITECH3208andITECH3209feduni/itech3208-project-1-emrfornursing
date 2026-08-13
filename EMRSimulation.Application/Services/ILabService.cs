using EMRSimulation.Domain.Dtos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EMRSimulation.Application.Services
{
    public interface ILabService
    {
        Task<LabDto> GetLabById(int Id);

        /// <summary>All labs, for the multi-lab module load picker.</summary>
        Task<IEnumerable<LabDto>> GetLabsAsync(bool includeInactive = false);
    }
}
