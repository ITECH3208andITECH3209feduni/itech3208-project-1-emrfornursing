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
   Any other procedure referencing a column that no longer exists?
   ---------------------------------------------------------------------------
   This is the check that would have caught the problem before the export left
   the building. A procedure can compile and sit in the database indefinitely
   before anyone notices.
   =========================================================================== */
SELECT  OBJECT_NAME(referencing_id) AS Procedure_,
        referenced_entity_name      AS Table_,
        referenced_minor_name       AS MissingColumn_
FROM    sys.sql_expression_dependencies
WHERE   referenced_minor_id > 0
  AND   referenced_id IS NOT NULL
  AND   NOT EXISTS (SELECT 1 FROM sys.columns c
                    WHERE c.[object_id] = referenced_id
                      AND c.[name]      = referenced_minor_name)
ORDER BY 1, 2;
GO
