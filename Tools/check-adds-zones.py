#!/usr/bin/env python3
"""
Catch the ADDS chart and the ADDS list drifting apart on zone colours.

The entry form (_patientAddsChart.cshtml) colours each observation using the
data-color attribute on whichever option the user selected. The observation
list has no such attribute available - it only has the stored text - so it
looks the colour up in AddsZones.cs instead. AddsZones.cs was generated from
those same options originally; this script cross-checks them and exits
non-zero the moment they no longer match.

    python Tools/check-adds-zones.py

Run this after editing either file. Nothing in the build catches this on its
own - both sides compile just fine while showing a nurse two different zones
for the same reading.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VIEW = ROOT / "EMRSimulationWebApp" / "Views" / "Patient" / "_patientAddsChart.cshtml"
ZONES = ROOT / "EMRSimulation.Domain" / "Clinical" / "AddsZones.cs"

# select id in the view -> field constant in AddsZones.cs
FIELDS = {
    "ddlRespiratory":   "RespiratoryRate",
    "ddlO2Sat":         "OxygenSaturation",
    "ddlO2Flow":        "OxygenFlow",
    "ddlBpRate":        "BloodPressure",
    "ddlHeartRate":     "HeartRate",
    "ddlTemperatureC":  "Temperature",
    "ddlConsciousness": "Consciousness",
}
NAMES = {
    "White": "#FFFFFF", "Yellow": "#FFFF00", "LightOrange": "#FFDBBB",
    "Orange": "#FFA500", "Purple": "#A020F0",
}

# A > inside a quoted attribute value must not end the tag: value=">= 12".
TAG = r'(?:[^>"]|"[^"]*")*'


def read_view():
    text = VIEW.read_text(encoding="utf-8")
    select_re = re.compile(r'<select' + TAG + r'id="(?P<id>[A-Za-z0-9_]+)"' + TAG + r'>(?P<body>.*?)</select>', re.S)
    option_re = re.compile(r'<option(?P<attrs>' + TAG + r')>', re.S)
    by_field = {}
    for select_match in select_re.finditer(text):
        field = FIELDS.get(select_match.group("id"))
        if not field:
            continue                      # mode of delivery and diastolic are not scored
        colours = {}
        for option_match in option_re.finditer(select_match.group("body")):
            attrs = option_match.group("attrs")
            value_match = re.search(r'value="([^"]*)"', attrs)
            colour_match = re.search(r'data-color="([^"]*)"', attrs)
            if value_match and colour_match and value_match.group(1):
                colours[value_match.group(1)] = colour_match.group(1).upper()
        by_field[field] = colours
    return by_field


def read_zones():
    text = ZONES.read_text(encoding="utf-8")
    by_field = {}
    block_re = re.compile(r'\[(?P<field>\w+)\]\s*=\s*new Dictionary<string, string>\([^)]*\)\s*\{(?P<body>.*?)\n\s*\},', re.S)
    row_re = re.compile(r'\["(?P<value>(?:[^"\\]|\\.)*)"\]\s*=\s*(?P<colour>\w+)')
    for block_match in block_re.finditer(text):
        colours = {}
        for row_match in row_re.finditer(block_match.group("body")):
            colours[row_match.group("value").replace('\\"', '"')] = NAMES[row_match.group("colour")]
        by_field[block_match.group("field")] = colours
    return by_field


def main():
    view_fields, zone_fields = read_view(), read_zones()
    mismatches = []

    for field in sorted(set(view_fields) | set(zone_fields)):
        view_colours, zone_colours = view_fields.get(field, {}), zone_fields.get(field, {})
        for value in sorted(set(view_colours) | set(zone_colours)):
            if value not in view_colours:
                mismatches.append(f"{field}: '{value}' is in AddsZones.cs but no longer an option in the chart")
            elif value not in zone_colours:
                mismatches.append(f"{field}: '{value}' is an option in the chart but missing from AddsZones.cs")
            elif view_colours[value] != zone_colours[value]:
                mismatches.append(f"{field}: '{value}' is {view_colours[value]} in the chart but {zone_colours[value]} in AddsZones.cs")

    if mismatches:
        print("ADDS zone mismatch - the chart and the list would disagree:\n")
        for mismatch in mismatches:
            print("  " + mismatch)
        print(f"\n{len(mismatches)} problem(s).")
        return 1

    total_options = sum(len(colours) for colours in view_fields.values())
    print(f"ADDS zones agree: {total_options} scored options across {len(view_fields)} fields.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
