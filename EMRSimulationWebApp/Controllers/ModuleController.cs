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
        private readonly ILabService _labService;

        public ModuleController(IModuleService moduleService, IPatientService patientService, ILabService labService)
        {
            _moduleService = moduleService;
            _patientService = patientService;
            _labService = labService;
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
        /// Explicit 403 rather than Forbid(). Under cookie authentication Forbid()
        /// redirects to AccessDeniedPath, which does not exist here, so a blocked
        /// student saw a 404 from an AJAX call - indistinguishable from a broken
        /// URL. The action was correctly refused either way; only the response was
        /// misleading.
        /// </summary>
        private IActionResult SupervisorOnly()
            => StatusCode(403, "This action is only available to a Supervisor login.");

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
            if (!IsSupervisor()) return SupervisorOnly();
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
            if (!IsSupervisor()) return SupervisorOnly();
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
            if (!IsSupervisor()) return SupervisorOnly();
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
            if (!IsSupervisor()) return SupervisorOnly();
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
            if (!IsSupervisor()) return SupervisorOnly();

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
        /// <summary>
        /// The labs a module can be loaded into, with a flag for the caller's own.
        /// Supervisor only - this drives the load picker.
        /// </summary>
        public async Task<IActionResult> GetLoadTargets(int moduleId)
        {
            if (!IsSupervisor()) return SupervisorOnly();

            var ownLabId = CreatedBy() ?? 0;
            var labs = await _labService.GetLabsAsync();

            // Which of them already hold a copy of THIS module. Those will have their
            // existing copy replaced, so the picker marks them as destructive.
            var alreadyLoaded = new Dictionary<int, DateTime?>();
            foreach (var lab in labs)
            {
                var loads = await _moduleService.GetLabModuleLoadsAsync(lab.Id);
                var match = loads.FirstOrDefault(l => l.ModuleId == moduleId);
                if (match != null) alreadyLoaded[lab.Id] = match.LoadedIntoLabAt;
            }

            return Ok(labs.Select(l => new
            {
                labId    = l.Id,
                labName  = l.LabName,
                isOwn    = l.Id == ownLabId,
                loaded   = alreadyLoaded.ContainsKey(l.Id),
                loadedAt = alreadyLoaded.TryGetValue(l.Id, out var when) ? when : null
            }));
        }

        /// <summary>
        /// Copies the module into one or more campus labs, ready for class.
        ///
        /// Labs now come from the request, because academics asked to prepare a
        /// scenario once and push it to every campus. That is a deliberate change:
        /// previously the target was taken from the caller's own claim precisely so
        /// one campus could not write into another's lab. The protection that remains
        /// is that this is supervisor-only, and that the confirmation names every lab
        /// whose existing copy - and whose students' work - will be replaced.
        ///
        /// An empty list falls back to the caller's own lab.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> LoadIntoLab([FromBody] LoadIntoLabRequest request)
        {
            if (!IsSupervisor()) return SupervisorOnly();
            if (request == null || request.ModuleId <= 0) return BadRequest("A module must be selected.");

            var targets = (request.LabIds ?? new List<int>()).Where(id => id > 0).Distinct().ToList();

            if (targets.Count == 0)
            {
                var own = CreatedBy();
                if (own == null || own <= 0)
                    return BadRequest("Your login is not associated with a campus lab, so a module cannot be loaded.");
                targets.Add(own.Value);
            }

            // Only labs that actually exist, so a crafted request cannot create
            // orphaned patients against a lab id that was never real.
            var known = (await _labService.GetLabsAsync(includeInactive: true)).ToDictionary(l => l.Id, l => l.LabName);
            var unknown = targets.Where(id => !known.ContainsKey(id)).ToList();
            if (unknown.Any())
                return BadRequest($"Unknown lab: {string.Join(", ", unknown)}.");

            var results = new List<object>();
            var failures = new List<string>();
            var replacedCount = 0;

            // Each lab is loaded independently. One failing must not leave the others
            // half-done and unreported, so failures are collected rather than thrown.
            foreach (var labId in targets)
            {
                try
                {
                    var result = await _moduleService.LoadModuleIntoLabAsync(request.ModuleId, labId);
                    if (result == null)
                    {
                        failures.Add($"{known[labId]}: no result returned");
                        continue;
                    }

                    if (result.WasReplaced) replacedCount++;

                    results.Add(new
                    {
                        labId,
                        labName     = known[labId],
                        patientId   = result.PatientId,
                        replaced    = result.WasReplaced,
                        rowsRemoved = result.RowsRemoved
                    });
                }
                catch (Exception ex)
                {
                    failures.Add($"{known[labId]}: {ex.Message}");
                }
            }

            var loadedInto = results.Count;

            var message = loadedInto == 0
                ? "The module was not loaded."
                : $"Module loaded into {loadedInto} lab{(loadedInto == 1 ? "" : "s")}"
                  + (replacedCount > 0
                        ? $". {replacedCount} existing cop{(replacedCount == 1 ? "y was" : "ies were")} replaced, including anything students had written."
                        : ".");

            if (failures.Any())
                message += " Failed: " + string.Join("; ", failures);

            return Ok(new
            {
                success = loadedInto > 0,
                loaded  = results,
                failed  = failures,
                resultMessage = message
            });
        }

        /// <summary>
        /// Which modules are already sitting in the caller's lab. Used by the
        /// repository screen to show when each was last loaded.
        /// </summary>
        public async Task<IActionResult> GetLabModuleLoads()
        {
            // Readable by both roles. The badge was supervisor-only on the grounds
            // that Naomi's student workflow is an ordinary patient list, but the team
            // asked for it everywhere: a student should also be able to see that the
            // patient they are working on came from a module and will be reset. It
            // reveals only the scenario name, which is on the timetable anyway.
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

    /// <summary>Which module to load, and into which labs.</summary>
    public class LoadIntoLabRequest
    {
        public int ModuleId { get; set; }

        /// <summary>
        /// Labs to load into. Empty means the caller's own lab. Supervisors may
        /// select other campuses - see the note on LoadIntoLab.
        /// </summary>
        public List<int>? LabIds { get; set; }
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
