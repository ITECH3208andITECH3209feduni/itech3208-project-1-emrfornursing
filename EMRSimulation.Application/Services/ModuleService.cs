using EMRSimulation.Application.Interfaces;
using EMRSimulation.Domain.Dtos;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EMRSimulation.Application.Services
{
    /// <summary>
    /// Application service for the global module repository.
    /// Sprint 3, Requirement 1.
    /// </summary>
    public class ModuleService : IModuleService
    {
        private readonly IModuleRepository _moduleRepository;

        public ModuleService(IModuleRepository moduleRepository)
        {
            _moduleRepository = moduleRepository;
        }

        public Task<IEnumerable<YearLevelDto>> GetYearLevelsAsync(bool includeInactive = false)
            => _moduleRepository.GetYearLevelsAsync(includeInactive);

        public Task<int> AddYearLevelAsync(YearLevelDto dto)
            => dto.Id > 0
                ? _moduleRepository.UpdateYearLevelAsync(dto)
                : _moduleRepository.InsertYearLevelAsync(dto);

        public Task<IEnumerable<UnitDto>> GetUnitsAsync(int yearLevelId = 0, bool includeInactive = false)
            => _moduleRepository.GetUnitsAsync(yearLevelId, includeInactive);

        public Task<int> AddUnitAsync(UnitDto dto)
            => dto.Id > 0
                ? _moduleRepository.UpdateUnitAsync(dto)
                : _moduleRepository.InsertUnitAsync(dto);

        public Task<IEnumerable<ModuleDto>> GetModulesAsync(int yearLevelId = 0, int unitId = 0,
                                                            string? searchTerm = null,
                                                            bool includeInactive = false)
            => _moduleRepository.GetModulesAsync(yearLevelId, unitId, searchTerm, includeInactive);

        public Task<ModuleDto?> GetModuleByIdAsync(int moduleId)
            => _moduleRepository.GetModuleByIdAsync(moduleId);

        public Task<int> AddModuleAsync(ModuleDto dto, int? createdBySupervisorId, bool createBlankPatient = true)
            => dto.Id > 0
                ? _moduleRepository.UpdateModuleAsync(dto)
                : _moduleRepository.InsertModuleAsync(dto, createdBySupervisorId, createBlankPatient);

        public async Task<int> RenameModuleAsync(int moduleId, string newName, string? description)
        {
            var existing = await _moduleRepository.GetModuleByIdAsync(moduleId);
            if (existing == null)
                throw new InvalidOperationException($"Module {moduleId} was not found.");

            existing.ModuleName = newName;

            // A null description means "leave the current one alone", so an
            // academic renaming a module cannot accidentally wipe its notes.
            if (description != null) existing.Description = description;

            return await _moduleRepository.UpdateModuleAsync(existing);
        }

        public Task<int> CopyModuleAsync(int sourceModuleId, string newModuleName, int targetUnitId,
                                         string? description, int? createdBySupervisorId)
            => _moduleRepository.CopyModuleAsync(sourceModuleId, newModuleName, targetUnitId,
                                                 description, createdBySupervisorId);

        public Task<IEnumerable<(string TableName, int RowsDeleted)>> DeleteModuleAsync(int moduleId)
            => _moduleRepository.DeleteModuleAsync(moduleId);

        public Task<IEnumerable<PatientDto>> GetPatientsByModuleAsync(int moduleId)
            => _moduleRepository.GetPatientsByModuleAsync(moduleId);

        public Task<ModuleLoadResultDto?> LoadModuleIntoLabAsync(int moduleId, int labId)
            => _moduleRepository.LoadModuleIntoLabAsync(moduleId, labId);

        public Task<IEnumerable<LabModuleLoadDto>> GetLabModuleLoadsAsync(int labId)
            => _moduleRepository.GetLabModuleLoadsAsync(labId);
    }
}
