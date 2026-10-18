namespace EMRSimulation.Domain.Dtos
{
    public class MedicationChartOrderDto
    {
        public int Id { get; set; }
        public int LabId { get; set; }
        public int PatientId { get; set; }
        public string MedicationType { get; set; } = "Regular";
        public string MedicationName { get; set; } = string.Empty;
        public string Strength { get; set; } = string.Empty;
        // UI-only value used when a supervisor enters the strength as a value + measure.
        // The repository persists the combined value in Strength, so no database migration is required.
        public string Measure { get; set; } = string.Empty;
        public string Route { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public string MaximumDose { get; set; } = string.Empty;
        public string Indication { get; set; } = string.Empty;
        public string PrescriberName { get; set; } = string.Empty;
        public string PrescriberSignature { get; set; } = string.Empty;
        public DateTime StartDate { get; set; } = DateTime.Today;
        public DateTime? EndDate { get; set; }
        public string Status { get; set; } = "Active";
        public DateTime? DiscontinuedAt { get; set; }
        public string? DiscontinuedBy { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public List<int> ScheduleHours { get; set; } = new();
    }
}
