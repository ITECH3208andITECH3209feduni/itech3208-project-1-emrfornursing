using System;
using System.Collections.Generic;

namespace EMRSimulation.Domain.Dtos
{
    /// <summary>
    /// Maps to [dbo].[FluidBalanceChart].
    /// One record = one 24-hour chart day for a patient.
    /// </summary>
    public class FluidBalanceChartDto
    {
        public int  Id        { get; set; }
        public int? LabId     { get; set; }
        public int? PatientId { get; set; }

        /// <summary>ChartDate - NOT NULL in the DB.</summary>
        public DateTime ChartDate { get; set; }

        /// <summary>ChartTime stored as HH:mm string - maps to SQL time(7).</summary>
        public string ChartTime { get; set; }

        public int PreviousDayBalance { get; set; }
        public int TotalIntake        { get; set; }
        public int TotalOutput        { get; set; }

        /// <summary>Balance = TotalIntake - TotalOutput</summary>
        public int Balance { get; set; }

        /// <summary>TotalBalance = Balance + PreviousDayBalance</summary>
        public int TotalBalance { get; set; }

        public string ClinicalNotes { get; set; }

        /// <summary>Aggregated distinct initials from chart entries (derived in SP).</summary>
        public string CompletedBy { get; set; }

        /// <summary>Base-64 PNG string captured from the signature canvas.</summary>
        public string SignatureData { get; set; }

        public DateTime  CreatedDateTime    { get; set; }
        public DateTime? UpdatedDateTime    { get; set; }
        /// <summary>Earliest EntryDate across all child entries (fluid admin date).</summary>
        public DateTime  EarliestEntryDate  { get; set; }
        /// <summary>Latest EntryDate - may differ if entries span midnight.</summary>
        public DateTime  LatestEntryDate    { get; set; }

        /// <summary>Child entries - populated when reading a single chart by Id.</summary>
        public List<FluidBalanceChartEntryDto> Entries { get; set; }
            = new List<FluidBalanceChartEntryDto>();
    }
}