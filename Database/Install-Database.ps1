<#
.SYNOPSIS
    Creates an empty database and runs the two install scripts into it.

.DESCRIPTION
    Automates the manual SSMS steps: New Database, run the schema export,
    run the starter data, check the counts. Refuses to touch a database
    that already has tables unless -Force.

    Windows auth by default. For SQL auth, pass -Credential (Get-Credential).

.EXAMPLE
    .\Install-Database.ps1
    .\Install-Database.ps1 -Database EmrSimulator_Test -AppSettings ..\EMRSimulationWebApp\appsettings.json
#>

[CmdletBinding()]
param(
    [string]$ServerInstance = '.\SQLEXPRESS',
    [string]$Database       = 'EmrSimulator_Test',
    [string]$ScriptRoot,
    [string]$AppSettings,                                  # optional: repoint the app at this database
    [switch]$Force,                                        # allow a database that already has tables
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'
Import-Module SqlServer -ErrorAction Stop

if (-not $ScriptRoot) { $ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path } }
$schemaFile = Join-Path $ScriptRoot 'EMRSimulatorFULL-spr4.sql'
$seedFile   = Join-Path $ScriptRoot 'sqlusers_and_yearLevels.sql'
foreach ($f in @($schemaFile, $seedFile)) {
    if (-not (Test-Path -LiteralPath $f)) { throw "Not found: $f" }
}

$common = @{ ServerInstance = $ServerInstance; TrustServerCertificate = $true; QueryTimeout = 0 }
if ($Credential) { $common.Credential = $Credential }

# ---------------------------------------------------------------------------
# 1. Create the database
# ---------------------------------------------------------------------------
$exists = Invoke-Sqlcmd @common -Database master -Query "SELECT 1 AS x FROM sys.databases WHERE name = '$Database'"

if ($exists) {
    $tables = (Invoke-Sqlcmd @common -Database $Database -Query "SELECT COUNT(*) AS n FROM sys.tables WHERE is_ms_shipped = 0").n
    if ($tables -gt 0 -and -not $Force) {
        throw "[$Database] already has $tables tables. Use a new name, or -Force to run into it anyway."
    }
    Write-Host "Using existing database [$Database]."
}
else {
    # No file paths specified, so SQL Server uses the instance's own defaults.
    Invoke-Sqlcmd @common -Database master -Query "CREATE DATABASE [$Database]"
    Write-Host "Created database [$Database]."
}

# ---------------------------------------------------------------------------
# 2. Schema, then starter data
# ---------------------------------------------------------------------------
Write-Host "Running $(Split-Path $schemaFile -Leaf)..."
Invoke-Sqlcmd @common -Database $Database -InputFile $schemaFile | Out-Null

Write-Host "Running $(Split-Path $seedFile -Leaf)..."
Invoke-Sqlcmd @common -Database $Database -InputFile $seedFile | Out-Null

# ---------------------------------------------------------------------------
# 3. Confirm
# ---------------------------------------------------------------------------
$counts = Invoke-Sqlcmd @common -Database $Database -Query @"
SELECT 'Tables'       AS Item_, COUNT(*) AS Count_ FROM sys.tables WHERE is_ms_shipped = 0
UNION ALL SELECT 'Procedures', COUNT(*) FROM sys.procedures WHERE is_ms_shipped = 0
UNION ALL SELECT 'Labs',        COUNT(*) FROM dbo.Lab
UNION ALL SELECT 'Supervisors', COUNT(*) FROM dbo.Supervisor
UNION ALL SELECT 'Year levels', COUNT(*) FROM dbo.YearLevel
UNION ALL SELECT 'Units',       COUNT(*) FROM dbo.Unit
UNION ALL SELECT 'Patients',    COUNT(*) FROM dbo.Patient
"@

Write-Host ''
$counts | ForEach-Object { '  {0,-12} {1}' -f $_.Item_, $_.Count_ | Write-Host }

$expected = @{ 'Tables' = 27; 'Procedures' = 93; 'Labs' = 1; 'Supervisors' = 1; 'Year levels' = 3; 'Units' = 6; 'Patients' = 0 }
$bad = @($counts | Where-Object { $expected[$_.Item_] -ne $_.Count_ })

Write-Host ''
if ($bad) {
    foreach ($b in $bad) { Write-Warning ('{0}: got {1}, expected {2}' -f $b.Item_, $b.Count_, $expected[$b.Item_]) }
}
else {
    Write-Host 'Install clean. Logins: lab123 / lab123 and super / super' -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 4. Point the app at it
# ---------------------------------------------------------------------------
if ($AppSettings) {
    if (-not (Test-Path -LiteralPath $AppSettings)) { throw "Not found: $AppSettings" }

    # Every appsettings*.json in the folder, not just the one named. In
    # Development, appsettings.Development.json overrides the base file, so
    # patching only the base leaves the app on the old database.
    $dir   = if (Test-Path -LiteralPath $AppSettings -PathType Container) { $AppSettings } else { Split-Path -Parent $AppSettings }
    $files = @(Get-ChildItem -LiteralPath $dir -Filter 'appsettings*.json' -File)
    if (-not $files) { throw "No appsettings*.json found in $dir" }

    foreach ($f in $files) {
        $json = Get-Content -LiteralPath $f.FullName -Raw
        if ($json -notmatch 'Database=') { continue }
        $new = [regex]::Replace($json, 'Database=[^;"]*', "Database=$Database")
        if ($new -ne $json) {
            Copy-Item -LiteralPath $f.FullName -Destination "$($f.FullName).bak" -Force
            Set-Content -LiteralPath $f.FullName -Value $new -NoNewline
            Write-Host "  Repointed $($f.Name) at [$Database] (original saved as .bak)."
        }
        else {
            Write-Host "  $($f.Name) already points at [$Database]."
        }
    }
}
