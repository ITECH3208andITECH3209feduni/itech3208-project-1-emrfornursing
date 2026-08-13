using System;

namespace EMRSimulation.Domain.Dtos
{
    /// <summary>
    /// A unit of study within a year level, e.g. "NURBN2019 Clinical Practice 2".
    /// Maps to dbo.Unit.
    /// </summary>
    public class UnitDto
    {
        public int Id { get; set; }
        public int YearLevelId { get; set; }
        public string? UnitCode { get; set; }
        public string? UnitName { get; set; }
        public int SortOrder { get; set; }
        public bool Active { get; set; }
        public DateTime CreatedDate { get; set; }

        /// <summary>Joined in by GetUnits for display; not stored on dbo.Unit.</summary>
        public string? YearLevelName { get; set; }

        /// <summary>Derived by GetUnits; not stored.</summary>
        public int ModuleCount { get; set; }
    }
}
