#!/usr/bin/env python3
"""
Guard against the ADDS chart and the ADDS list disagreeing about zone colours.

The entry form (_patientAddsChart.cshtml) shades each observation from the
data-color attribute on the option the user picked. The observation list has no
such attribute to read, only the stored text, so it looks the colour up in
AddsZones.cs. AddsZones.cs was generated from those same options - this script
re-compares them and exits non-zero if they have drifted apart.

    python Tools/check-adds-zones.py

Run it after editing either file. There is no build step that would catch this:
both sides compile perfectly well while showing a nurse two different zones for
the same reading.
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


def from_view():
    src = VIEW.read_text(encoding="utf-8")
    sel = re.compile(r'<select' + TAG + r'id="(?P<id>[A-Za-z0-9_]+)"' + TAG + r'>(?P<body>.*?)</select>', re.S)
    opt = re.compile(r'<option(?P<attrs>' + TAG + r')>', re.S)
    found = {}
    for m in sel.finditer(src):
        field = FIELDS.get(m.group("id"))
        if not field:
            continue                      # mode of delivery and diastolic are not scored
        pairs = {}
        for o in opt.finditer(m.group("body")):
            a = o.group("attrs")
            v = re.search(r'value="([^"]*)"', a)
            c = re.search(r'data-color="([^"]*)"', a)
            if v and c and v.group(1):
                pairs[v.group(1)] = c.group(1).upper()
        found[field] = pairs
    return found


def from_zones():
    src = ZONES.read_text(encoding="utf-8")
    found = {}
    block = re.compile(r'\[(?P<field>\w+)\]\s*=\s*new Dictionary<string, string>\([^)]*\)\s*\{(?P<body>.*?)\n\s*\},', re.S)
    row = re.compile(r'\["(?P<value>(?:[^"\\]|\\.)*)"\]\s*=\s*(?P<colour>\w+)')
    for m in block.finditer(src):
        pairs = {}
        for r in row.finditer(m.group("body")):
            pairs[r.group("value").replace('\\"', '"')] = NAMES[r.group("colour")]
        found[m.group("field")] = pairs
    return found


def main():
    view, zones = from_view(), from_zones()
    problems = []

    for field in sorted(set(view) | set(zones)):
        v, z = view.get(field, {}), zones.get(field, {})
        for value in sorted(set(v) | set(z)):
            if value not in v:
                problems.append(f"{field}: '{value}' is in AddsZones.cs but no longer an option in the chart")
            elif value not in z:
                problems.append(f"{field}: '{value}' is an option in the chart but missing from AddsZones.cs")
            elif v[value] != z[value]:
                problems.append(f"{field}: '{value}' is {v[value]} in the chart but {z[value]} in AddsZones.cs")

    if problems:
        print("ADDS zone mismatch - the chart and the list would disagree:\n")
        for p in problems:
            print("  " + p)
        print(f"\n{len(problems)} problem(s).")
        return 1

    total = sum(len(p) for p in view.values())
    print(f"ADDS zones agree: {total} scored options across {len(view)} fields.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
