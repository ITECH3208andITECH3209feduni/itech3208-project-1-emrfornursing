using System;
using System.Collections.Generic;

namespace EMRSimulation.Domain.Clinical
{
    /// <summary>
    /// The ADDS scoring zones, in one place.
    ///
    /// The ADDS chart entry form shades each observation from the data-color
    /// attribute on the option the user picked. The observation list has no such
    /// attribute to read - it only has the stored text - so it looks the colour up
    /// here instead. Both screens must agree, or the same reading would appear in
    /// two different zones depending on which screen a nurse was looking at.
    ///
    /// This table was generated from the option lists in _patientAddsChart.cshtml,
    /// so the two start out identical. Tools/check-adds-zones.py re-compares them
    /// and fails if the view is edited without updating this file.
    ///
    /// Mode of delivery and diastolic blood pressure are deliberately absent:
    /// neither is scored by ADDS, so neither is ever shaded.
    /// </summary>
    public static class AddsZones
    {
        public const string White       = "#FFFFFF";
        public const string Yellow      = "#FFFF00";
        public const string LightOrange = "#FFDBBB";
        public const string Orange      = "#FFA500";
        public const string Purple      = "#A020F0";

        // Field keys - these match the AddsDto property names.
        public const string RespiratoryRate = "RespiratoryRate";
        public const string OxygenSaturation = "OxygenSaturation";
        public const string OxygenFlow = "OxygenFlow";
        public const string BloodPressure = "BloodPressure";
        public const string HeartRate = "HeartRate";
        public const string Temperature = "Temperature";
        public const string Consciousness = "Consciousness";

        private static readonly Dictionary<string, Dictionary<string, string>> Zones =
            new Dictionary<string, Dictionary<string, string>>(StringComparer.OrdinalIgnoreCase)
            {
                [RespiratoryRate] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["Write >= 35"] = Purple     , // score 4
                    ["30-34"] = Orange     , // score 3
                    ["25-29"] = LightOrange, // score 2
                    ["20-24"] = Yellow     , // score 1
                    ["15-19"] = White      , // score 0
                    ["10-14"] = White      , // score 0
                    ["5-9"] = Orange     , // score 3
                    ["Write <= 4"] = Purple     , // score 4
                },
                [OxygenSaturation] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["98-100"] = White      , // score 0
                    ["95-97"] = White      , // score 0
                    ["93-94"] = Yellow     , // score 1
                    ["90-92"] = LightOrange, // score 2
                    ["87-89"] = Orange     , // score 3
                    ["85-86"] = Orange     , // score 3
                    ["Write <= 84"] = Purple     , // score 4
                },
                [OxygenFlow] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    [">= 12"] = Orange     , // score 3
                    ["10-11"] = LightOrange, // score 2
                    ["7-9"] = Yellow     , // score 1
                    ["4-6"] = White      , // score 0
                    ["<=3"] = White      , // score 0
                },
                [BloodPressure] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["Write >= 200"] = Orange     , // score 3
                    ["190s"] = LightOrange, // score 2
                    ["180s"] = LightOrange, // score 2
                    ["170s"] = LightOrange, // score 2
                    ["160s"] = Yellow     , // score 1
                    ["150s"] = White      , // score 0
                    ["140s"] = White      , // score 0
                    ["130s"] = White      , // score 0
                    ["120s"] = White      , // score 0
                    ["110s"] = White      , // score 0
                    ["100s"] = LightOrange, // score 2
                    ["90s"] = Orange     , // score 3
                    ["80s"] = Purple     , // score 4
                    ["70s"] = Purple     , // score 4
                    ["60s"] = Purple     , // score 4
                    ["50s"] = Purple     , // score 4
                    ["40s"] = Purple     , // score 4
                },
                [HeartRate] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["Write >= 140"] = Purple     , // score 4
                    ["130s"] = Orange     , // score 3
                    ["120s"] = LightOrange, // score 2
                    ["110s"] = LightOrange, // score 2
                    ["100s"] = Yellow     , // score 1
                    ["90s"] = White      , // score 0
                    ["80s"] = White      , // score 0
                    ["70s"] = White      , // score 0
                    ["60s"] = White      , // score 0
                    ["50s"] = White      , // score 0
                    ["40s"] = Yellow     , // score 1
                    ["Write >= 30s"] = Purple     , // score 4
                },
                [Temperature] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["Write >= 39.1"] = LightOrange, // score 2
                    ["38.5-39.0"] = LightOrange, // score 2
                    ["38.0-38.4"] = Yellow     , // score 1
                    ["37.5-37.9"] = White      , // score 0
                    ["37.0-37.4"] = White      , // score 0
                    ["36.5-36.9"] = White      , // score 0
                    ["36.0-36.4"] = White      , // score 0
                    ["35.5-35.9"] = White      , // score 0
                    ["Write <= 35.4"] = Orange     , // score 3
                },
                [Consciousness] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["Alert"] = White      , // score 0
                    ["To Voice"] = LightOrange, // score 2
                    ["To Pain"] = Orange     , // score 3
                    ["Unresponsive"] = Purple     , // score 4
                },
            };

        /// <summary>Zone colour for a stored observation. Unknown or blank values are not shaded.</summary>
        public static string ColourFor(string field, string value)
        {
            if (string.IsNullOrWhiteSpace(field) || string.IsNullOrWhiteSpace(value))
                return White;

            return Zones.TryGetValue(field, out var options)
                   && options.TryGetValue(value.Trim(), out var colour)
                ? colour
                : White;
        }

        /// <summary>
        /// Zone for the ADDS total. Eight or above is the emergency call threshold
        /// (Australian Commission on Safety and Quality in Health Care, 2021).
        /// </summary>
        public static string TotalColour(int total)
        {
            if (total >= 8) return Purple;      // emergency call
            if (total >= 6) return Orange;
            if (total >= 4) return LightOrange;
            if (total >= 1) return Yellow;
            return White;                       // routine observations
        }

        /// <summary>Readable text colour for a cell painted with the given zone.</summary>
        public static string TextColourFor(string zoneColour)
            => string.Equals(zoneColour, Purple, StringComparison.OrdinalIgnoreCase)
               ? "#FFFFFF"
               : "#111111";
    }
}
