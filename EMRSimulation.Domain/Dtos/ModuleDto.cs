using System;

namespace EMRSimulation.Domain.Dtos
{
    /// <summary>
    /// A single laboratory scenario, e.g. "Week 2 - Post-operative care".
    /// Maps to dbo.Module.
    ///
    /// Modules live in one global repository shared by every campus Supervisor
    /// login, so this DTO deliberately carries no LabId. Ownership is recorded
    /// only as CreatedBySupervisorId, for audit, and is never used to filter.
    /// </summary>
    public class ModuleDto
    {
        public int Id { get; set; }
        public int UnitId { get; set; }
        public string? ModuleName { get; set; }
        public string? Description { get; set; }
        public int SortOrder { get; set; }
        public bool Active { get; set; }
        public int? CreatedBySupervisorId { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        /// <summary>Joined in by GetModules / GetModuleById for display.</summary>
        public string? UnitCode { get; set; }
        public string? UnitName { get; set; }
        public int YearLevelId { get; set; }
        public string? YearLevelName { get; set; }

        /// <summary>Derived; number of patients belonging to this module.</summary>
        public int PatientCount { get; set; }
    }
}
