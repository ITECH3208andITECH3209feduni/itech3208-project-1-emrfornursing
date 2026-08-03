using System;

namespace EMRSimulation.Domain.Dtos
{
    /// <summary>
    /// What LoadModuleIntoLab did.
    ///
    /// Sprint 3, Requirement 1 - Naomi's "Option B": a module is a master copy
    /// that an academic loads into their campus lab before class. Students work
    /// on the copy; the module is never touched.
    /// </summary>
    public class ModuleLoadResultDto
    {
        /// <summary>The lab patient that was created. This is what students open.</summary>
        public int PatientId { get; set; }

        public int ModuleId { get; set; }
        public int LabId { get; set; }

        /// <summary>
        /// 1 when a previous copy of this module was already in this lab and has
        /// been replaced, 0 on a first load. Anything students had written into
        /// that previous copy is gone - that is what resetting means.
        /// </summary>
        public int ReplacedExistingCopy { get; set; }

        /// <summary>Rows removed with the previous copy, across every clinical table.</summary>
        public int RowsRemoved { get; set; }

        public bool WasReplaced => ReplacedExistingCopy > 0;
    }

    /// <summary>
    /// A module currently sitting in a lab, as reported by GetLabModuleLoads.
    /// Drives the "loaded" badge in the module repository.
    /// </summary>
    public class LabModuleLoadDto
    {
        public int ModuleId { get; set; }
        public int PatientId { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateTime? LoadedIntoLabAt { get; set; }

        /// <summary>Which scenario this copy came from, for the patient list badge.</summary>
        public string? ModuleName { get; set; }
    }
}
