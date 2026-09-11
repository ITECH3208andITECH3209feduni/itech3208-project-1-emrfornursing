/* ============================================================================
   ITECH3208 EMR Simulator - year level and unit seed

   RUN AFTER EMRSimulatorFULL-spr3.sql AND users.sql. SAFE TO RE-RUN.

   Why this file exists
   ---------------------------------------------------------------------------
   EMRSimulatorFULL-spr3.sql is a schema-only export: tables and stored
   procedures, no rows. A module must belong to a Unit, and a Unit must belong
   to a YearLevel, so without these rows the Global Module Repository cannot be
   used at all - there is nothing to create a module under.

   This content used to live in the Sprint 3 migration scripts, which have been
   removed now that the baseline export is current. The schema came with them;
   the seed data did not, so it is kept here.

   The unit codes were supplied by Chelsea Webb and answer the open question
   about what sits under each year level.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

/* ===========================================================================
   1. Year levels
   =========================================================================== */
INSERT INTO [dbo].[YearLevel] ([YearLevelName], [SortOrder], [Active], [CreatedDate])
SELECT v.Name, v.SortOrder, 1, GETDATE()
FROM   (VALUES ('Year 1 Nursing', 1),
               ('Year 2 Nursing', 2),
               ('Year 3 Nursing', 3)) AS v(Name, SortOrder)
WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[YearLevel] y WHERE y.[YearLevelName] = v.Name);

PRINT 'Year levels added: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

/* ===========================================================================
   2. Units
   ---------------------------------------------------------------------------
   UnitName is NOT NULL and Chelsea supplied codes only, so the code doubles as
   the name until she provides titles. Both are shown in the pickers anyway.
   =========================================================================== */
DECLARE @Units TABLE (YearLevelName VARCHAR(50), UnitCode VARCHAR(20), SortOrder INT);

INSERT INTO @Units (YearLevelName, UnitCode, SortOrder) VALUES
    ('Year 1 Nursing', 'NURBN1104', 1),
    ('Year 1 Nursing', 'NURBN1108', 2),
    ('Year 2 Nursing', 'NURBN2104', 1),
    ('Year 2 Nursing', 'NURBN2108', 2),
    ('Year 3 Nursing', 'NURBN3104', 1),
    ('Year 3 Nursing', 'NURBN3108', 2);

INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder], [Active], [CreatedDate])
SELECT  y.[Id], u.UnitCode, u.UnitCode, u.SortOrder, 1, GETDATE()
FROM    @Units u
JOIN    [dbo].[YearLevel] y ON y.[YearLevelName] = u.YearLevelName
WHERE   NOT EXISTS (SELECT 1 FROM [dbo].[Unit] e
                    WHERE e.[YearLevelId] = y.[Id] AND e.[UnitCode] = u.UnitCode);

PRINT 'Units added: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

/* Older databases carry "<Year> - Unassigned" placeholder units created before
   Chelsea supplied the real codes. They are deactivated rather than deleted:
   modules created earlier still point at one, and removing it would orphan
   them. Move those modules onto a real unit, then the placeholder can go. */
UPDATE [dbo].[Unit]
SET    [Active] = 0
WHERE  [UnitName] LIKE '%Unassigned%' AND [Active] = 1;

PRINT 'Placeholder units deactivated: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

/* ===========================================================================
   3. Confirmation
   =========================================================================== */
SELECT  y.[YearLevelName], u.[UnitCode], u.[UnitName], u.[Active]
FROM    [dbo].[Unit] u
JOIN    [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
ORDER BY y.[SortOrder], u.[Active] DESC, u.[SortOrder];
GO
