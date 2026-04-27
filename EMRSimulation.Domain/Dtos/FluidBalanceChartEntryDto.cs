using System;

namespace EMRSimulation.Domain.Dtos
{
    public class FluidBalanceChartEntryDto
    {
        public int      Id                  { get; set; }
        public int      FluidBalanceChartId { get; set; }
        public DateTime EntryDate           { get; set; }
        public string   EntryTime           { get; set; } = string.Empty;
        public string   EntryType           { get; set; } = string.Empty;
        public string   Category            { get; set; } = string.Empty;
        public int      AmountMl            { get; set; }
        public string   Initials            { get; set; }
        public DateTime CreatedDateTime     { get; set; }
    }
}
