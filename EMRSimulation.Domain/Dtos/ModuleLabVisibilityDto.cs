using System;

namespace EMRSimulation.Domain.Dtos
{
    /// <summary>
    /// One laboratory that currently holds a copy of a module, and whether the
    /// students in that laboratory can see it.
    ///
    /// Visibility is per laboratory rather than per module because campuses run
    /// their own timetables: Berwick may be running Week 3 while Gippsland is
    /// still on Week 2, and hiding a scenario at one must not hide it at the
    /// other. Only laboratories that actually hold a copy appear - there is
    /// nothing to show or hide anywhere else.
    /// </summary>
    public class ModuleLabVisibilityDto
    {
        public int Id { get; set; }

        public string? LabName { get; set; }

        /// <summary>Loaded patients from this module sitting in this laboratory.</summary>
        public int PatientCount { get; set; }

        /// <summary>How many of them are currently hidden.</summary>
        public int HiddenCount { get; set; }

        /// <summary>
        /// False only when every loaded patient is hidden. A partial state can
        /// arise only from direct database editing; HiddenCount exposes it rather
        /// than rounding it off silently.
        /// </summary>
        public bool VisibleToStudents { get; set; } = true;

        public DateTime? LoadedIntoLabAt { get; set; }
    }
}
