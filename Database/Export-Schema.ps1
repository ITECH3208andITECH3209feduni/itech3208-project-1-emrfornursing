<#
.SYNOPSIS
    Scripts the EMR database schema to a .sql file. Replaces the SSMS
    Generate Scripts wizard.

.DESCRIPTION
    Uses SMO - the same library the wizard drives - with the settings we
    settled on, so they can't be mis-clicked:

        Tables and stored procedures only  (no CREATE DATABASE, no ALTER
                                            DATABASE with hardcoded paths)
        Schema only, no data               (no patient rows, no policy
                                            blobs, no lab credentials)
        No USE statement                   (runs against whatever database
                                            you select)
        Indexes, keys and defaults on
        UTF-8 with BOM                     (so no editor guesses UTF-16)

    Setup, once:
        Install-Module SqlServer -Scope CurrentUser -AllowClobber

    -AllowClobber is needed because SQL Server ships an older SQLPS module
    whose command names overlap.

.EXAMPLE
    .\Export-Schema.ps1
    .\Export-Schema.ps1 -Database EmrSimulator_Test -Out .\EMRSimulatorFULL-spr5.sql
#>

[CmdletBinding()]
param(
    [string]$ServerInstance = '.\SQLEXPRESS',
    [string]$Database       = 'EmrSimulator',
    [string]$Out,
    [switch]$NoHeaders                       # drop the /****** Object: ... ******/ banners
)

$ErrorActionPreference = 'Stop'

# $PSScriptRoot is empty if this was pasted into the console rather than run
# as a file, so fall back to the working directory.
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
if (-not $Out) { $Out = Join-Path $scriptDir 'EMRSimulatorFULL-spr4.sql' }
$Out = [System.IO.Path]::GetFullPath($Out)

try {
    Import-Module SqlServer -ErrorAction Stop
}
catch {
    throw "Could not load the SqlServer module. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}

# Older SMO builds don't have every option. Skip what isn't there rather than
# failing the whole export.
function Set-Opt {
    param($Options, [string]$Name, $Value)
    if ($Options.PSObject.Properties.Name -contains $Name) { $Options.$Name = $Value }
    else { Write-Verbose "Scripting option '$Name' not supported by this SMO version - skipped." }
}

$server = New-Object Microsoft.SqlServer.Management.Smo.Server $ServerInstance
$db     = $server.Databases[$Database]
if (-not $db) { throw "Database '$Database' not found on $ServerInstance." }

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $server
$o = $scripter.Options

Set-Opt $o ScriptSchema           $true
Set-Opt $o ScriptData             $false     # the setting that leaked 26 MB of patient data
Set-Opt $o IncludeDatabaseContext $false     # no USE [EmrSimulator]
Set-Opt $o IncludeHeaders         (-not $NoHeaders)
Set-Opt $o Indexes                $true      # off by default when scripting selected objects
Set-Opt $o DriAll                 $true      # PKs, FKs, unique keys, defaults, checks
Set-Opt $o Triggers               $false
Set-Opt $o ExtendedProperties     $false
Set-Opt $o Permissions            $false
Set-Opt $o ScriptBatchTerminator  $true      # GO between batches
Set-Opt $o AnsiPadding            $false
Set-Opt $o NoCollation            $true
Set-Opt $o ScriptDrops            $false
Set-Opt $o IncludeIfNotExists     $false
Set-Opt $o Encoding               (New-Object System.Text.UTF8Encoding($true))
Set-Opt $o ToFileOnly             $true
Set-Opt $o FileName               $Out

# Tables first, then procedures - the order the wizard emits and the order
# they have to run in.
$urns = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
$tableList = @($db.Tables           | Where-Object { -not $_.IsSystemObject })
$procList  = @($db.StoredProcedures | Where-Object { -not $_.IsSystemObject })
foreach ($t in $tableList) { $urns.Add($t.Urn) }
foreach ($p in $procList)  { $urns.Add($p.Urn) }

Write-Host "Scripting $($tableList.Count) tables and $($procList.Count) procedures from [$Database] -> $Out"
$scripter.Script($urns) | Out-Null

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
$text   = [System.IO.File]::ReadAllText($Out)
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
    @{ Name = 'data rows';       Pattern = '(?im)^INSERT\s' },
    @{ Name = 'USE statement';   Pattern = '(?im)^\s*USE\s+\[' },
    @{ Name = 'CREATE DATABASE'; Pattern = '(?im)^\s*CREATE\s+DATABASE\b' },
    @{ Name = 'ALTER DATABASE';  Pattern = '(?im)^\s*ALTER\s+DATABASE\b' }
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
if ($text -match 'SetModuleVisibility') { Write-Warning 'Stale SetModuleVisibility is present.'; $fail = $true }

Write-Host ''
if ($fail) { Write-Warning 'Exported with warnings above.' }
else       { Write-Host "Clean. Run this against an empty database, then sqlusers_and_yearLevels.sql." -ForegroundColor Green }
