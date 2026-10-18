using EMRSimulation.Domain.Dtos;

namespace EMRSimulationWebApp.Models
{
    public class MedicationChartViewModel
    {
        public PatientDto Patient { get; set; } = new();
        public int LabId { get; set; }
        public int PatientId { get; set; }
        public DateTime SelectedDate { get; set; } = DateTime.Today;
        // Existing medication names configured in the EMR (Settings > Add Medication Name).
        // Sprint 5 reuses this catalogue instead of making supervisors re-type medication names.
        public IReadOnlyList<MedicationDto> MedicationCatalogue { get; set; } = Array.Empty<MedicationDto>();
        public IReadOnlyList<MedicationChartOrderDto> Orders { get; set; } = Array.Empty<MedicationChartOrderDto>();
        public IReadOnlyList<MedicationChartAdministrationDto> Administrations { get; set; } = Array.Empty<MedicationChartAdministrationDto>();
    }
}
