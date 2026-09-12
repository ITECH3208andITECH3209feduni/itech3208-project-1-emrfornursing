<#
.SYNOPSIS
    Scripts the EMR database schema to a .sql file. Replaces the SSMS
    Generate Scripts wizard.

.DESCRIPTION
    Uses SMO - the same library the wizard drives - with the settings we
    settled on, so the output matches what the wizard produces:

        Tables and stored procedures only  (no database object, so no
                                            CREATE DATABASE and no ALTER
                                            DATABASE with hardcoded paths)
        Schema only, no data               (no patient rows, no policy
                                            blobs, no lab credentials)
        No USE statement                   (runs against whatever database
                                            you select)
        Indexes, keys and defaults on
        UTF-8 with BOM                     (so no editor guesses UTF-16)

    One-time setup:  Install-Module SqlServer -Scope CurrentUser

.EXAMPLE
    .\Export-Schema.ps1
    .\Export-Schema.ps1 -Database EmrSimulator_Test -Out .\EMRSimulatorFULL-spr5.sql
#>

[CmdletBinding()]
param(
    [string]$ServerInstance = '.\SQLEXPRESS',
    [string]$Database       = 'EmrSimulator',
    [string]$Out            = (Join-Path $PSScriptRoot 'EMRSimulatorFULL-spr4.sql'),
    [switch]$NoHeaders                       # drop the /****** Object: ... ******/ banners
)

$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

$server = New-Object Microsoft.SqlServer.Management.Smo.Server $ServerInstance
$db     = $server.Databases[$Database]
if (-not $db) { throw "Database '$Database' not found on $ServerInstance." }

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $server
$o = $scripter.Options

$o.ScriptSchema            = $true
$o.ScriptData              = $false      # the one setting that leaked 26 MB of patient data
$o.IncludeDatabaseContext  = $false      # no USE [EmrSimulator]
$o.IncludeHeaders          = -not $NoHeaders
$o.Indexes                 = $true       # off by default when scripting selected objects
$o.DriAll                  = $true       # PKs, FKs, unique keys, defaults, checks
$o.Triggers                = $false
$o.ExtendedProperties      = $false
$o.Permissions             = $false
$o.ScriptBatchTerminator   = $true       # GO between batches
$o.AnsiPadding             = $false
$o.NoCollation             = $true
$o.ScriptDrops             = $false
$o.IncludeIfNotExists      = $false
$o.Encoding                = New-Object System.Text.UTF8Encoding($true)
$o.ToFileOnly              = $true
$o.FileName                = $Out

# Tables first, then procedures - the order the wizard emits and the order
# they have to run in.
$urns = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
foreach ($t in $db.Tables           | Where-Object { -not $_.IsSystemObject }) { $urns.Add($t.Urn) }
foreach ($p in $db.StoredProcedures | Where-Object { -not $_.IsSystemObject }) { $urns.Add($p.Urn) }

Write-Host "Scripting $($db.Tables.Count) tables and $($db.StoredProcedures.Count) procedures from [$Database]..."
$scripter.Script($urns) | Out-Null

# ---------------------------------------------------------------------------
# Validation - the point of the exercise
# ---------------------------------------------------------------------------
$text = [System.IO.File]::ReadAllText($Out)

$tables = ([regex]::Matches($text, '(?im)^CREATE TABLE \[dbo\]\.\[(\w+)\]')).Count
$procs  = @([regex]::Matches($text, '(?im)^CREATE\s+PROC(?:EDURE)?\s+\[?dbo\]?\.\[?(\w+)\]?') |
            ForEach-Object { $_.Groups[1].Value })

Write-Host ''
Write-Host ("  Tables      {0}" -f $tables)
Write-Host ("  Procedures  {0} ({1} distinct)" -f $procs.Count, (@($procs | Sort-Object -Unique).Count))
Write-Host ("  Indexes     {0}" -f ([regex]::Matches($text, '(?im)^CREATE\s+(?:UNIQUE\s+)?NONCLUSTERED INDEX')).Count)
Write-Host ("  Size        {0:N0} bytes" -f (Get-Item $Out).Length)

$fail = $false
foreach ($check in @(
    @{ Name = 'data rows';        Pattern = '(?im)^INSERT\s' },
    @{ Name = 'USE statement';    Pattern = '(?im)^\s*USE\s+\[' },
    @{ Name = 'CREATE DATABASE';  Pattern = '(?im)^\s*CREATE\s+DATABASE\b' },
    @{ Name = 'ALTER DATABASE';   Pattern = '(?im)^\s*ALTER\s+DATABASE\b' }
)) {
    $n = ([regex]::Matches($text, $check.Pattern)).Count
    if ($n -gt 0) { Write-Warning ("{0}: {1} found - must be zero." -f $check.Name, $n); $fail = $true }
}

$dupes = $procs | Group-Object | Where-Object Count -gt 1
if ($dupes) { Write-Warning ('Duplicate procedures: ' + (($dupes | ForEach-Object { $_.Name }) -join ', ')); $fail = $true }

# Sprint 4 objects. Absent means the export came from a stale database.
$missing = @('HiddenFromStudents','IX_Patient_SourceModule_Lab_Hidden','GetModuleLabVisibility',
             'SetModuleLabVisibility','@IncludeHiddenModules','@PatientCount') |
           Where-Object { $text -notmatch [regex]::Escape($_) }
if ($missing) { Write-Warning ('Missing: ' + ($missing -join ', ')); $fail = $true }

# Dropped in Sprint 4. Present means the database still has it.
if ($text -match 'SetModuleVisibility') { Write-Warning "Stale SetModuleVisibility is present."; $fail = $true }

Write-Host ''
if ($fail) { Write-Warning "Exported with warnings above." }
else       { Write-Host "Clean. Run $Out against an empty database, then sqlusers_and_yearLevels.sql." -ForegroundColor Green }
