/* ============================================================================
   Drop the superseded SetModuleVisibility procedure

   RUN AGAINST YOUR OWN DEVELOPMENT DATABASE. SAFE TO RE-RUN.

   Why
   ---------------------------------------------------------------------------
   Module visibility was first built as a single flag on Module. It was then
   reworked to be per laboratory, because campuses run their own timetables and
   hiding a scenario at Berwick must not hide it at Gippsland. The flag moved
   onto the loaded patient rows as Patient.HiddenFromStudents, the old
   Module.VisibleToStudents column was dropped, and SetModuleLabVisibility
   replaced this procedure.

   The old procedure was never dropped. SQL Server uses deferred name
   resolution, so a procedure referencing a column that no longer exists is
   allowed to sit there and only fails when it is executed - or, as happened
   here, when the database is scripted and that script is run against a fresh
   database:

       Msg 207, Level 16, State 1, Procedure SetModuleVisibility, Line 15
       Invalid column name 'VisibleToStudents'.

   Nothing calls it. The application uses SetModuleLabVisibility and
   GetModuleLabVisibility.

   Run this, then re-export EMRSimulatorFULL-spr4.sql so the stale procedure
   stops being scripted into it.
   ============================================================================ */

USE [EmrSimulator];
GO

IF OBJECT_ID('[dbo].[SetModuleVisibility]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[SetModuleVisibility];
    PRINT 'Dropped the superseded dbo.SetModuleVisibility.';
END
ELSE
    PRINT 'dbo.SetModuleVisibility is not present - nothing to do.';
GO

/* ===========================================================================
   Confirmation: the replacements are present and the stale one is gone
   =========================================================================== */
SELECT 'SetModuleVisibility (should be gone)' AS Object_,
       CASE WHEN OBJECT_ID('[dbo].[SetModuleVisibility]', 'P') IS NULL
            THEN 'removed' ELSE 'STILL PRESENT' END AS State_
UNION ALL
SELECT 'SetModuleLabVisibility',
       CASE WHEN OBJECT_ID('[dbo].[SetModuleLabVisibility]', 'P') IS NOT NULL
            THEN 'present' ELSE 'MISSING' END
UNION ALL
SELECT 'GetModuleLabVisibility',
       CASE WHEN OBJECT_ID('[dbo].[GetModuleLabVisibility]', 'P') IS NOT NULL
            THEN 'present' ELSE 'MISSING' END
UNION ALL
SELECT 'Patient.HiddenFromStudents',
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns
                         WHERE [object_id] = OBJECT_ID('dbo.Patient')
                           AND [name] = 'HiddenFromStudents')
            THEN 'present' ELSE 'MISSING' END;
GO

/* ===========================================================================
   Any other module referencing something that no longer exists?
   ---------------------------------------------------------------------------
   This is the check that would have caught the problem before the export left
   the building. SQL Server uses deferred name resolution, so a procedure that
   references a dropped column compiles, sits in the database indefinitely, and
   only fails when it is executed or scripted into a fresh database.

   sys.dm_sql_referenced_entities resolves each module's references and throws
   when one cannot be resolved, so the failures are collected per object.
   Read-only: nothing is altered.
   =========================================================================== */
SET NOCOUNT ON;

DECLARE @Broken TABLE (ObjectName SYSNAME, Problem NVARCHAR(1000));
DECLARE @name SYSNAME;

DECLARE modules CURSOR LOCAL FAST_FORWARD FOR
    SELECT QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)
    FROM   sys.objects
    WHERE  type IN ('P', 'V', 'FN', 'IF', 'TF', 'TR')
      AND  is_ms_shipped = 0;

OPEN modules;
FETCH NEXT FROM modules INTO @name;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        /* Referencing a missing column or object makes this throw. */
        DECLARE @ignore INT;
        SELECT @ignore = COUNT(*)
        FROM   sys.dm_sql_referenced_entities(@name, 'OBJECT');
    END TRY
    BEGIN CATCH
        INSERT INTO @Broken (ObjectName, Problem) VALUES (@name, ERROR_MESSAGE());
    END CATCH

    FETCH NEXT FROM modules INTO @name;
END

CLOSE modules;
DEALLOCATE modules;

IF EXISTS (SELECT 1 FROM @Broken)
    SELECT 'Modules with unresolved references - fix before exporting' AS Result_,
           ObjectName, Problem
    FROM   @Broken
    ORDER  BY ObjectName;
ELSE
    SELECT 'No module references a missing object or column.' AS Result_;
GO
