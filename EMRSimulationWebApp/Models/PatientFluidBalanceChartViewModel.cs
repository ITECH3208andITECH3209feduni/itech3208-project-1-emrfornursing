using EMRSimulation.Domain.Dtos;

namespace EMRSimulationWebApp.Models
{
    public class PatientFluidBalanceChartViewModel
    {
        public PatientDto? patientDto                              { get; set; }
        public FluidBalanceChartDto? FluidBalanceChartDto          { get; set; }
        public IEnumerable<FluidBalanceChartDto>? FluidBalanceChartDtoList { get; set; }
        public IEnumerable<FluidBalanceChartEntryDto>? FluidBalanceChartEntryDtoList { get; set; }
        /// <summary>TotalBalance from the patient's most recent chart (0 if none).</summary>
        public int PreviousDayBalanceAuto                          { get; set; }
    }
}
