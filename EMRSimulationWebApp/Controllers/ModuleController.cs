using EMRSimulation.Application.Services;
using EMRSimulation.Domain.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EMRSimulationWebApp.Controllers
{
    /// <summary>
    /// Sprint 3, Requirement 1 - global module repository.
    ///
    /// SUPERVISOR ONLY. Naomi's brief is explicit that students must not be able
    /// to create, copy, rename, edit or delete modules, so every action that
    /// changes the repository is gated on the "supervisor" role claim. The two
    /// read actions are also gated, since the repository browser is a Supervisor
    /// View feature; students reach module content through the normal patient
    /// screens once a module has been selected for them.
    /// </summary>
    [Authorize]
    public class ModuleController : Controller
    {
        private readonly IModuleService _moduleService;
        private readonly IPatientService _patientService;

        public ModuleController(IModuleService moduleService, IPatientService patientService)
        {
            _moduleService = moduleService;
            _patientService = patientService;
        }

        /// <summary>
        /// Only supervisors may change the repository. Students may read it -
        /// Naomi's student workflow is "select the required Year Level and Module,
        /// open the patient's EMR, view all documentation".
        /// </summary>
        private bool IsSupervisor()
            => string.Equals(User.FindFirst("Role")?.Value, "supervisor",
                             System.StringComparison.OrdinalIgnoreCase);

        /// <summary>
        /// Supervisor accounts are per campus and the claim carries labId, not a
        /// supervisor id, so ownership is recorded as the campus that created the
        /// module. It is audit information only - GetModules never filters on it.
        /// </summary>
        private int? CreatedBy()
            => int.TryParse(User.FindFirst("labId")?.Value, out var id) ? id : null;

        /* ------------------------------------------------------------------
           browse
           ------------------------------------------------------------------ */

        public async Task<IActionResult> GetModuleRepository(int yearLevelId = 0, int unitId = 0, string? searchTerm = null)
        {
            // Readable by both roles. CanManage drives whether the view renders
            // New / Copy / Rename / Delete at all.
            ViewData["CanManage"] = IsSupervisor();

            var vm = new ModuleRepositoryViewModel
            {
                YearLevels     = await _moduleService.GetYearLevelsAsync(),
                Units          = await _moduleService.GetUnitsAsync(yearLevelId),
                Modules        = await _moduleService.GetModulesAsync(yearLevelId, unitId, searchTerm),
                SelectedYearLevelId = yearLevelId,
                SelectedUnitId      = unitId,
                SearchTerm          = searchTerm
            };

            return PartialView("~/Views/Patient/_moduleRepository.cshtml", vm);
        }

        public async Task<IActionResult> GetModuleList(int yearLevelId = 0, int unitId = 0, string? searchTerm = null)
        {
            ViewData["CanManage"] = IsSupervisor();

            var modules = await _moduleService.GetModulesAsync(yearLevelId, unitId, searchTerm);
            return PartialView("~/Views/Patient/_moduleList.cshtml", modules);
        }

        public async Task<IActionResult> GetUnits(int yearLevelId = 0)
        {
            var units = await _moduleService.GetUnitsAsync(yearLevelId);
            return Ok(units.Select(u => new
            {
                id = u.Id,
                name = string.IsNullOrWhiteSpace(u.UnitCode) ? u.UnitName : $"{u.UnitCode} - {u.UnitName}",
                moduleCount = u.ModuleCount
            }));
        }

        /// <summary>
        /// Opens a module: its patient, with Select to set the patient context so
        /// the chart menus become usable. This is the step that makes a module
        /// populatable at all - the shared supervisor patient list has no Select,
        /// so reusing it left the chart screens unreachable.
        /// </summary>
        public async Task<IActionResult> GetModulePatients(int moduleId)
        {
            var module = await _moduleService.GetModuleByIdAsync(moduleId);
            if (module == null) return NotFound("Module not found.");

            var patients = await _moduleService.GetPatientsByModuleAsync(moduleId);

            return PartialView("~/Views/Patient/_modulePatientView.cshtml",
                new ModulePatientViewModel
                {
                    Module = module,
                    Patients = patients,
                    CanEdit = IsSupervisor()
                });
        }

        /// <summary>
        /// Saves the module patient's demographics. Supervisor only - students may
        /// read a module but never change it.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> UpdateModulePatient([FromBody] PatientDto dto)
        {
            if (!IsSupervisor()) return Forbid();
            if (dto == null || dto.Id <= 0) return BadRequest("An existing patient is required.");

            // Confirm the patient really is module-owned before writing. Without this
            // a crafted request could edit a campus patient through this endpoint.
            if (dto.ModuleId is null or <= 0)
                return BadRequest("This endpoint only edits module-owned patients.");

            var inModule = await _moduleService.GetPatientsByModuleAsync(dto.ModuleId.Value);
            if (!inModule.Any(p => p.Id == dto.Id))
                return BadRequest("That patient does not belong to the given module.");

            // LabId 0 keeps the patient in the global repository. UpdatePatient sets
            // LabId but never touches ModuleId, so module ownership survives the edit.
            dto.LabId = 0;

            try
            {
                await _patientService.AddPatientAsync(dto);
                return Ok(new { id = dto.Id, resultMessage = "Patient saved successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while saving the patient. " + ex.Message);
            }
        }

        /* ------------------------------------------------------------------
           create / copy / rename / delete
           ------------------------------------------------------------------ */

        [HttpPost]
        public async Task<IActionResult> AddModule([FromBody] ModuleDto dto)
        {
            if (!IsSupervisor()) return Forbid();
            if (dto == null) return BadRequest("Module data is required.");
            if (string.IsNullOrWhiteSpace(dto.ModuleName)) return BadRequest("Module name is required.");
            if (dto.UnitId <= 0) return BadRequest("A unit must be selected.");

            try
            {
                var newId = await _moduleService.AddModuleAsync(dto, CreatedBy());
                return Ok(new { id = newId, resultMessage = "Module saved successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while saving the module. " + ex.Message);
            }
        }

        [HttpPost]
        public async Task<IActionResult> CopyModule([FromBody] CopyModuleRequest request)
        {
            if (!IsSupervisor()) return Forbid();
            if (request == null) return BadRequest("Copy details are required.");
            if (request.SourceModuleId <= 0) return BadRequest("A source module must be selected.");
            if (string.IsNullOrWhiteSpace(request.NewModuleName)) return BadRequest("A name for the new module is required.");

            try
            {
                var newId = await _moduleService.CopyModuleAsync(
                    request.SourceModuleId,
                    request.NewModuleName,
                    request.TargetUnitId,
                    request.Description,
                    CreatedBy());

                return Ok(new { id = newId, resultMessage = "Module copied successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while copying the module. " + ex.Message);
            }
        }

        [HttpPost]
        public async Task<IActionResult> RenameModule([FromBody] RenameModuleRequest request)
        {
            if (!IsSupervisor()) return Forbid();
            if (request == null) return BadRequest("Rename details are required.");
            if (string.IsNullOrWhiteSpace(request.NewName)) return BadRequest("A new name is required.");

            try
            {
                var rows = await _moduleService.RenameModuleAsync(request.ModuleId, request.NewName, request.Description);
                return Ok(new { id = rows, resultMessage = "Module renamed successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while renaming the module. " + ex.Message);
            }
        }

        public async Task<IActionResult> DeleteModule(int moduleId)
        {
            if (!IsSupervisor()) return Forbid();

            try
            {
                var cleared = await _moduleService.DeleteModuleAsync(moduleId);
                return Ok(cleared.Select(c => new { tableName = c.TableName, rowsDeleted = c.RowsDeleted }));
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while deleting the module. " + ex.Message);
            }
        }

        /* ------------------------------------------------------------------
           loading a module into a lab (Option B)
           ------------------------------------------------------------------ */

        /// <summary>
        /// Copies the module into the caller's own campus lab, ready for class.
        ///
        /// The target lab comes from the signed-in supervisor's claim and is
        /// never accepted from the request. Taking it from the client would let
        /// one campus load a scenario over another campus's lab and delete their
        /// students' work - the same class of mistake as trusting txtLabId at
        /// write time, which caused the cross-campus leak earlier this sprint.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> LoadIntoLab([FromBody] LoadIntoLabRequest request)
        {
            if (!IsSupervisor()) return Forbid();
            if (request == null || request.ModuleId <= 0) return BadRequest("A module must be selected.");

            var labId = CreatedBy();
            if (labId == null || labId <= 0)
                return BadRequest("Your login is not associated with a campus lab, so a module cannot be loaded.");

            try
            {
                var result = await _moduleService.LoadModuleIntoLabAsync(request.ModuleId, labId.Value);

                if (result == null)
                    return StatusCode(500, "The module was not loaded. No result was returned.");

                var message = result.WasReplaced
                    ? "Module loaded. The previous copy in this lab was replaced, including anything students had written into it."
                    : "Module loaded into your lab. It will now appear in the patient list.";

                return Ok(new
                {
                    patientId    = result.PatientId,
                    replaced     = result.WasReplaced,
                    rowsRemoved  = result.RowsRemoved,
                    resultMessage = message
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while loading the module. " + ex.Message);
            }
        }

        /// <summary>
        /// Which modules are already sitting in the caller's lab. Used by the
        /// repository screen to show when each was last loaded.
        /// </summary>
        public async Task<IActionResult> GetLabModuleLoads()
        {
            // Supervisor only. Naomi's student workflow is a normal patient list -
            // students should not be told which patients are module copies, and it
            // is not information they can act on.
            if (!IsSupervisor()) return Ok(Array.Empty<object>());

            var labId = CreatedBy();
            if (labId == null || labId <= 0) return Ok(Array.Empty<object>());

            var loads = await _moduleService.GetLabModuleLoadsAsync(labId.Value);

            return Ok(loads.Select(l => new
            {
                moduleId    = l.ModuleId,
                moduleName  = l.ModuleName,
                patientId   = l.PatientId,
                patientName = ($"{l.FirstName} {l.LastName}").Trim(),
                loadedAt    = l.LoadedIntoLabAt
            }));
        }
    }

    /* ----------------------------------------------------------------------
       request / view models
       ---------------------------------------------------------------------- */

    /// <summary>
    /// Carries only the module. The lab is taken from the caller's claim, so it
    /// is deliberately absent here - there is nothing for a client to set.
    /// </summary>
    public class LoadIntoLabRequest
    {
        public int ModuleId { get; set; }
    }

    public class CopyModuleRequest
    {
        public int SourceModuleId { get; set; }
        public string NewModuleName { get; set; } = string.Empty;

        /// <summary>0 keeps the copy in the same unit as the source.</summary>
        public int TargetUnitId { get; set; }
        public string? Description { get; set; }
    }

    public class RenameModuleRequest
    {
        public int ModuleId { get; set; }
        public string NewName { get; set; } = string.Empty;

        /// <summary>Null leaves the existing description untouched.</summary>
        public string? Description { get; set; }
    }

    public class ModulePatientViewModel
    {
        public ModuleDto? Module { get; set; }
        public IEnumerable<PatientDto> Patients { get; set; } = new List<PatientDto>();

        /// <summary>False for students: they read a module, they never change it.</summary>
        public bool CanEdit { get; set; }
    }

    public class ModuleRepositoryViewModel
    {
        public IEnumerable<YearLevelDto> YearLevels { get; set; } = new List<YearLevelDto>();
        public IEnumerable<UnitDto> Units { get; set; } = new List<UnitDto>();
        public IEnumerable<ModuleDto> Modules { get; set; } = new List<ModuleDto>();
        public int SelectedYearLevelId { get; set; }
        public int SelectedUnitId { get; set; }
        public string? SearchTerm { get; set; }
    }
}
