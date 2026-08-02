using System;

namespace EMRSimulation.Domain.Dtos
{
    /// <summary>
    /// A nursing year level, e.g. "Year 1 Nursing". Top of the
    /// YearLevel -> Unit -> Module hierarchy. Maps to dbo.YearLevel.
    /// </summary>
    public class YearLevelDto
    {
        public int Id { get; set; }
        public string? YearLevelName { get; set; }
        public int SortOrder { get; set; }
        public bool Active { get; set; }
        public DateTime CreatedDate { get; set; }

        /// <summary>Derived by GetYearLevels; not stored.</summary>
        public int UnitCount { get; set; }
    }
}
