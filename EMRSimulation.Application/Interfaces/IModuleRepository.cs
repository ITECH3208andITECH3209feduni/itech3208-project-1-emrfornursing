using EMRSimulation.Domain.Dtos;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EMRSimulation.Application.Interfaces
{
    /// <summary>
    /// Data access for the global module repository
    /// (YearLevel -> Unit -> Module -> Patient).
    ///
    /// Sprint 3, Requirement 1. Wraps the stored procedures created by
    /// Database/Sprint3_02_ModuleRepository_Procs.sql.
    /// </summary>
    public interface IModuleRepository
    {
        // ---- year levels ----
        Task<IEnumerable<YearLevelDto>> GetYearLevelsAsync(bool includeInactive = false);
        Task<int> InsertYearLevelAsync(YearLevelDto dto);
        Task<int> UpdateYearLevelAsync(YearLevelDto dto);

        // ---- units ----
        Task<IEnumerable<UnitDto>> GetUnitsAsync(int yearLevelId = 0, bool includeInactive = false);
        Task<int> InsertUnitAsync(UnitDto dto);
        Task<int> UpdateUnitAsync(UnitDto dto);

        // ---- modules ----
        Task<IEnumerable<ModuleDto>> GetModulesAsync(int yearLevelId = 0, int unitId = 0,
                                                     string? searchTerm = null,
                                                     bool includeInactive = false);
        Task<ModuleDto?> GetModuleByIdAsync(int moduleId);
        Task<int> InsertModuleAsync(ModuleDto dto, int? createdBySupervisorId, bool createBlankPatient = true);
        Task<int> UpdateModuleAsync(ModuleDto dto);
        Task<int> CopyModuleAsync(int sourceModuleId, string newModuleName, int targetUnitId,
                                  string? description, int? createdBySupervisorId);

        /// <summary>Returns per-table deleted row counts, as DeleteModule reports them.</summary>
        Task<IEnumerable<(string TableName, int RowsDeleted)>> DeleteModuleAsync(int moduleId);

        // ---- module contents ----
        Task<IEnumerable<PatientDto>> GetPatientsByModuleAsync(int moduleId);
    }
}
