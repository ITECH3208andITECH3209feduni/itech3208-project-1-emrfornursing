using EMRSimulation.Domain.Dtos;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EMRSimulation.Application.Services
{
    /// <summary>
    /// Application service for the global module repository.
    /// Sprint 3, Requirement 1.
    /// </summary>
    public interface IModuleService
    {
        Task<IEnumerable<YearLevelDto>> GetYearLevelsAsync(bool includeInactive = false);
        Task<int> AddYearLevelAsync(YearLevelDto dto);

        Task<IEnumerable<UnitDto>> GetUnitsAsync(int yearLevelId = 0, bool includeInactive = false);
        Task<int> AddUnitAsync(UnitDto dto);

        Task<IEnumerable<ModuleDto>> GetModulesAsync(int yearLevelId = 0, int unitId = 0,
                                                     string? searchTerm = null,
                                                     bool includeInactive = false);
        Task<ModuleDto?> GetModuleByIdAsync(int moduleId);

        /// <summary>Creates a new module, or updates it when dto.Id is already set.</summary>
        Task<int> AddModuleAsync(ModuleDto dto, int? createdBySupervisorId, bool createBlankPatient = true);

        Task<int> RenameModuleAsync(int moduleId, string newName, string? description);

        /// <summary>Every lab holding a copy of this module, with its student visibility.</summary>
        Task<IEnumerable<ModuleLabVisibilityDto>> GetModuleLabVisibilityAsync(int moduleId);

        /// <summary>Show or hide one module's loaded patients from students in one lab.</summary>
        Task<int> SetModuleLabVisibilityAsync(int moduleId, int labId, bool visibleToStudents);
        Task<int> CopyModuleAsync(int sourceModuleId, string newModuleName, int targetUnitId,
                                  string? description, int? createdBySupervisorId);
        Task<IEnumerable<(string TableName, int RowsDeleted)>> DeleteModuleAsync(int moduleId);

        Task<IEnumerable<PatientDto>> GetPatientsByModuleAsync(int moduleId);

        /// <summary>
        /// Loads the module into a lab as a working copy. Replaces any previous
        /// copy of the same module in the same lab, including anything students
        /// wrote into it.
        /// </summary>
        Task<ModuleLoadResultDto?> LoadModuleIntoLabAsync(int moduleId, int labId);

        Task<IEnumerable<LabModuleLoadDto>> GetLabModuleLoadsAsync(int labId);
    }
}
