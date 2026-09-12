<#
.SYNOPSIS
    Rebuilds Database\Install_EmrSimulator.sql from a fresh SSMS schema export.

.DESCRIPTION
    Install_EmrSimulator.sql is the one file Naomi, Evan or a marker runs to get
    a working database. It is assembled, not hand-maintained, because the schema
    half of it has to come out of the live database every time the schema moves.

    What SSMS gives you and why it cannot be used as-is
    --------------------------------------------------------------------------
    Tasks -> Generate Scripts produces a file that opens with USE [master],
    CREATE DATABASE [EmrSimulator] carrying the absolute data-file paths of the
    machine it was scripted on, about thirty ALTER DATABASE settings, and closes
    with USE [master] plus SET READ_WRITE. Those paths are the problem: they
    name MSSQL16.SQLEXPRESS, so the script fails on any machine with a different
    SQL version, instance or data directory. Every run of it has also gone to a
    database called EmrSimulator whether the person wanted that or not.

    This script strips all of that out at batch granularity - a whole GO-
    separated batch is kept or dropped, never edited - so nothing inside a
    procedure body is touched. It then prepends the install header and guards
    and appends the two seed files, which the export does not contain because it
    is schema-only.

    Batch granularity matters. Earlier attempts at this used line regexes and
    kept producing false positives: FileName is a column on Policies, and
    CREATE   PROCEDURE with two spaces hid thirteen procedures from a pattern
    expecting one. Dropping whole batches on an anchored match avoids both.

.PARAMETER ExportPath
    The fresh SSMS export. Tasks -> Generate Scripts -> whole database,
    schema only, single file. Defaults to EMRSimulatorFULL-spr4.sql beside this
    script. SSMS writes UTF-16 by default; that is handled.

.EXAMPLE
    .\Build-InstallScript.ps1 -ExportPath .\EMRSimulatorFULL-spr5.sql

.NOTES
    After running, read the validation report. It is the point of the exercise -
    it catches the class of failure Evan hit, where a procedure survived in the
    export referencing a column that had been dropped.
#>

[CmdletBinding()]
param(
    [string]$ExportPath = (Join-Path $PSScriptRoot 'EMRSimulatorFULL-spr4.sql'),
    [string]$UsersPath  = (Join-Path $PSScriptRoot 'users.sql'),
    [string]$SeedPath   = (Join-Path $PSScriptRoot 'Seed_YearLevelsAndUnits.sql'),
    [string]$OutputPath = (Join-Path $PSScriptRoot 'Install_EmrSimulator.sql')
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Reading
# ---------------------------------------------------------------------------

# SSMS writes UTF-16 LE with a BOM unless you change the save dialog, and git
# then treats the file as binary so no diff is ever readable. Decode from the
# BOM rather than trusting Get-Content's guess.
function Read-SqlText {
    param([Parameter(Mandatory)][string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)

    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [System.Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

# A batch is everything between lines consisting of GO on its own. "-- GO" and
# "GO" inside a string both survive, because the line is trimmed and anchored.
function Split-SqlBatches {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)

    $batches = New-Object System.Collections.Generic.List[string]
    $current = New-Object System.Collections.Generic.List[string]

    foreach ($line in ($Text -split "`r`n|`n|`r")) {
        if ($line.Trim() -match '^GO(\s+\d+)?$') {
            $batches.Add(($current -join "`r`n"))
            $current.Clear()
        }
        else {
            $current.Add($line)
        }
    }
    if ((($current -join '') -replace '\s', '').Length -gt 0) {
        $batches.Add(($current -join "`r`n"))
    }
    return $batches
}

foreach ($p in @($ExportPath, $UsersPath, $SeedPath)) {
    if (-not (Test-Path -LiteralPath $p)) { throw "Not found: $p" }
}

Write-Host "Export : $ExportPath"
Write-Host "Users  : $UsersPath"
Write-Host "Seed   : $SeedPath"
Write-Host "Output : $OutputPath"
Write-Host ''

# ---------------------------------------------------------------------------
# Filtering
# ---------------------------------------------------------------------------

# Any batch matching one of these is dropped whole. Each is anchored to the
# start of a line so that a procedure mentioning the words in a comment or a
# column name is never caught.
$dropPatterns = [ordered]@{
    'USE'             = '(?im)^\s*USE\s+\['
    'CREATE DATABASE' = '(?im)^\s*CREATE\s+DATABASE\b'
    'ALTER DATABASE'  = '(?im)^\s*ALTER\s+DATABASE\b'
    'vardecimal'      = '(?im)^\s*EXEC\s+sys\.sp_db_vardecimal_storage_format\b'
    'fulltext'        = '(?im)FULLTEXTSERVICEPROPERTY'
}

$schemaBatches = Split-SqlBatches (Read-SqlText $ExportPath)
$kept          = New-Object System.Collections.Generic.List[string]
$droppedCounts = [ordered]@{}
foreach ($k in $dropPatterns.Keys) { $droppedCounts[$k] = 0 }

foreach ($batch in $schemaBatches) {
    if ((($batch) -replace '\s', '').Length -eq 0) { continue }

    $reason = $null
    foreach ($k in $dropPatterns.Keys) {
        if ($batch -match $dropPatterns[$k]) { $reason = $k; break }
    }

    if ($reason) { $droppedCounts[$reason]++ }
    else         { $kept.Add($batch.TrimEnd()) }
}

Write-Host 'Batches dropped from the export:'
foreach ($k in $droppedCounts.Keys) { '  {0,-16} {1}' -f $k, $droppedCounts[$k] | Write-Host }
Write-Host ('  {0,-16} {1}' -f 'kept', $kept.Count)
Write-Host ''

# The seed files each start with USE [EmrSimulator]. The install deliberately
# has no USE at all, so it runs against whatever database is selected.
$usersBody = (Split-SqlBatches (Read-SqlText $UsersPath) |
    Where-Object { $_ -notmatch '(?im)^\s*USE\s+\[' -and ($_ -replace '\s','').Length -gt 0 }) -join "`r`nGO`r`n"

$seedBody = (Split-SqlBatches (Read-SqlText $SeedPath) |
    Where-Object { $_ -notmatch '(?im)^\s*USE\s+\[' -and ($_ -replace '\s','').Length -gt 0 }) -join "`r`nGO`r`n"

# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------

$preamble = @'
/* ============================================================================
   EMR for Nursing Simulator - complete database install

   ONE SCRIPT. Run it against an EMPTY database that you have already created
   and selected.

       1. In SSMS: right-click Databases -> New Database -> name it, OK
       2. Select that database in the dropdown (or run USE [YourDbName] first)
       3. Open this file and Execute

   There is deliberately no CREATE DATABASE here. The exported one carried the
   file paths of the machine it was scripted on
   (C:\Program Files\...\MSSQL16.SQLEXPRESS\...), which fails on any server
   with a different SQL version, instance or data directory. Creating the
   database yourself avoids that entirely.

   Contents, in order:
       1. Tables, indexes, foreign keys and stored procedures
       2. One laboratory and one supervisor login
       3. Three year levels and the six NURBN unit codes

   Section 3 is not optional. A module belongs to a Unit, which belongs to a
   YearLevel, and there is no screen to create either yet - without it the
   module repository opens but nothing can be created in it.

   Safe to run only on an empty database. It does not drop anything.

   GENERATED FILE - do not edit by hand. Rebuild it with
   Build-InstallScript.ps1 after taking a fresh export from the database.
   ============================================================================ */

SET NOCOUNT ON;
GO

/* ----------------------------------------------------------------------------
   Guards. Both abort the ENTIRE install, not just the batch they sit in.

   SET NOEXEC ON is what does the aborting. RAISERROR and THROW end only their
   own batch, so with GO-separated batches below them the script reports the
   error and then installs anyway - which is exactly what the first version of
   this file did. NOEXEC persists for the rest of the session, so every batch
   after a tripped guard is compiled and discarded. It is switched back off in
   the last batch of the file.

   Compiled, not skipped - so an aborted run can print follow-on errors such
   as Invalid object name. Those are compilation noise from batches that never
   executed. The first message is the real one, and the confirmation report at
   the end will be absent.

   DB_NAME() is read into a variable first. RAISERROR substitution arguments
   must be a variable or a literal - a function call there is a syntax error.

   Severity 16, not 20. Severity 20 aborts the connection and requires
   sysadmin, and WITH LOG requires it too, so on a student install the
   permission check fires before the real message is ever shown.
   ---------------------------------------------------------------------------- */
DECLARE @TargetDatabase SYSNAME = DB_NAME();

IF @TargetDatabase IN ('master', 'model', 'msdb', 'tempdb')
BEGIN
    RAISERROR('INSTALL ABORTED - nothing was created. The selected database is %s. Create an empty database, select it in the SSMS database dropdown, then run this file again. Ignore any errors printed below this line; they are batches being compiled and discarded.', 16, 1, @TargetDatabase);
    SET NOEXEC ON;
END
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Patient' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    RAISERROR('INSTALL ABORTED - nothing was changed. This database already contains the EMR schema. Use an empty database. Ignore any errors printed below this line.', 16, 1);
    SET NOEXEC ON;
END
GO

/* ============================================================================
   1. SCHEMA AND STORED PROCEDURES
   ============================================================================ */
'@

$usersHeader = @'

/* ============================================================================
   2. LABORATORY AND SUPERVISOR LOGINS

   Student:    lab123 / lab123
   Supervisor: super  / super

   Passwords are stored and compared in plain text. Acceptable for a simulator
   holding fictitious data on a closed network; change them before this is
   reachable from anywhere else.
   ============================================================================ */
'@

$seedHeader = @'

/* ============================================================================
   3. YEAR LEVELS AND UNITS
   ============================================================================ */
'@

$tail = @'

/* ============================================================================
   4. CONFIRMATION
   ============================================================================ */
SELECT 'Database'    AS Item_, DB_NAME()                                        AS Value_
UNION ALL SELECT 'Tables',      CAST(COUNT(*) AS VARCHAR(10)) FROM sys.tables WHERE is_ms_shipped = 0
UNION ALL SELECT 'Procedures',  CAST(COUNT(*) AS VARCHAR(10)) FROM sys.procedures WHERE is_ms_shipped = 0
UNION ALL SELECT 'Labs',        CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Lab]
UNION ALL SELECT 'Supervisors', CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Supervisor]
UNION ALL SELECT 'Year levels', CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[YearLevel]
UNION ALL SELECT 'Units',       CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Unit];
GO

PRINT 'Install complete.';
GO

/* ----------------------------------------------------------------------------
   Last batch. If a guard tripped, execution has been off since then and
   nothing above this line ran - including the confirmation report, whose
   absence is the signal that the install did not happen. Switch execution back
   on regardless so the connection is left usable.
   ---------------------------------------------------------------------------- */
SET NOEXEC OFF;
GO
'@

$parts = @(
    $preamble,
    ($kept -join "`r`nGO`r`n"),
    'GO',
    $usersHeader,
    $usersBody,
    'GO',
    $seedHeader,
    $seedBody,
    'GO',
    $tail
)

$out = $parts -join "`r`n"
$out = ($out -split "`r`n|`n|`r") -join "`r`n"   # normalise, mixed endings creep in from the here-strings

# UTF-8 with BOM: SSMS opens it correctly and git can diff it.
[System.IO.File]::WriteAllText($OutputPath, $out, (New-Object System.Text.UTF8Encoding($true)))

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

$text  = Read-SqlText $OutputPath
$lines = @($text -split "`r`n")

# @() around the whole pipeline, not just the Matches call: a single match would
# otherwise come back as a bare string with no useful .Count.
$tables = @([regex]::Matches($text, '(?im)^CREATE\s+TABLE\s+\[dbo\]\.\[(\w+)\]') |
            ForEach-Object { $_.Groups[1].Value })
$procs  = @([regex]::Matches($text, '(?im)^CREATE\s+PROC(?:EDURE)?\s+\[?dbo\]?\.\[?(\w+)\]?') |
            ForEach-Object { $_.Groups[1].Value })

Write-Host 'Validation'
Write-Host '----------'
'  Lines               {0}'      -f $lines.Count               | Write-Host
'  Tables              {0}'      -f $tables.Count              | Write-Host
'  Procedures          {0}'      -f $procs.Count               | Write-Host
'  Distinct procedures {0}'      -f (@($procs | Sort-Object -Unique).Count) | Write-Host

$dupes = $procs | Group-Object | Where-Object Count -gt 1
if ($dupes) {
    Write-Warning ('Duplicate procedure definitions: ' + (($dupes | ForEach-Object { '{0} x{1}' -f $_.Name, $_.Count }) -join ', '))
} else {
    Write-Host '  Duplicates          none'
}

# Statements that must not survive into the install.
$forbidden = [ordered]@{
    'USE'             = '(?im)^\s*USE\s+\['
    'CREATE DATABASE' = '(?im)^\s*CREATE\s+DATABASE\b'
    'ALTER DATABASE'  = '(?im)^\s*ALTER\s+DATABASE\b'
    'RAISERROR WITH LOG' = '(?im)RAISERROR\s*\(.*\)\s*WITH\s+LOG'
}
$bad = $false
foreach ($k in $forbidden.Keys) {
    $n = @([regex]::Matches($text, $forbidden[$k])).Count
    if ($n -gt 0) { Write-Warning ("{0} found {1} time(s) - the install must not contain it." -f $k, $n); $bad = $true }
}
if (-not $bad) { Write-Host '  Forbidden stmts     none' }

# Objects that were dropped from the database in Sprint 4. If one reappears the
# export was taken from a stale database, which is how the Invalid column name
# 'VisibleToStudents' failure reached Evan.
foreach ($stale in @('SetModuleVisibility')) {
    if ($text -match [regex]::Escape($stale)) {
        Write-Warning "Stale object '$stale' is present. The export came from a database that still has it - drop it and re-export."
        $bad = $true
    }
}

# Sprint 4 features that must be present. Their absence means the export
# predates the migrations.
$expected = @(
    'HiddenFromStudents',
    'IX_Patient_SourceModule_Lab_Hidden',
    'GetModuleLabVisibility',
    'SetModuleLabVisibility',
    '@IncludeHiddenModules',
    '@PatientCount'
)
$missing = @($expected | Where-Object { $text -notmatch [regex]::Escape($_) })
if ($missing) {
    Write-Warning ('Missing Sprint 4 objects: ' + ($missing -join ', '))
    $bad = $true
} else {
    Write-Host '  Sprint 4 features   all present'
}

# The export is schema-only, so the only rows created are the ones the two seed
# files add. Anything else means patient data leaked into a public repository.
$patientInserts = @([regex]::Matches($text, '(?im)^\s*INSERT\s+INTO\s+\[?dbo\]?\.?\[?Patient\]?')).Count
if ($patientInserts -gt 0) {
    Write-Warning "$patientInserts top-level INSERT INTO Patient found. Check for real patient data."
    $bad = $true
} else {
    Write-Host '  Patient data        none'
}

Write-Host ''
if ($bad) {
    Write-Warning 'Built with warnings above. Do not ship it until they are resolved.'
} else {
    Write-Host 'Built clean.' -ForegroundColor Green
}
