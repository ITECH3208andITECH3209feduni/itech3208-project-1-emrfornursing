namespace EMRSimulation.Domain.Dtos
{
    public class MedicationChartAdministrationDto
    {
        public int Id { get; set; }
        public int MedicationOrderId { get; set; }
        public int LabId { get; set; }
        public int PatientId { get; set; }
        public DateTime AdministrationDate { get; set; }
        public int AdministrationHour { get; set; }
        public string Status { get; set; } = "Given";
        public string Dose { get; set; } = string.Empty;
        public string GivenBy { get; set; } = string.Empty;
        public string CoSign { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
        public DateTime AdministeredAt { get; set; }
    }
}
