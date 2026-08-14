/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Client requests from Chelsea's email

   RUN AFTER Sprint3_08. SAFE TO RE-RUN.

   1. The real unit codes, replacing the "Unassigned" placeholders
   2. Five patients per module instead of one

   ============================================================================
   1. UNIT CODES
   ---------------------------------------------------------------------------
   Chelsea supplied them, which answers the open question about what should sit
   under each year level:

       First Year  : NURBN1104, NURBN1108
       Second Year : NURBN2104, NURBN2108
       Third Year  : NURBN3104, NURBN3108

   The "Unassigned" placeholders are NOT deleted. Modules created before this
   script point at them, and deleting a unit with modules attached would break
   the YearLevel -> Unit -> Module chain. They are deactivated instead, so they
   stop appearing in the pickers while existing modules keep working. Move those
   modules onto a real unit with Rename, then the placeholder can be removed.

   ============================================================================
   2. FIVE PATIENTS PER MODULE
   ---------------------------------------------------------------------------
   Chelsea: "could we have five patients available for each module? We can
   populate the patient details ourselves later, however it would be great to
   have five patients showing on one page".

   This reverses the one-patient-per-module design, which came from Naomi's
   documents describing "the patient" singular and was recorded as an assumption
   in the outstanding questions.

   The deep copy needed no change. CopyModule and LoadModuleIntoLab both copy
   patients as a set through MERGE ... OUTPUT and remap the child rows through
   @MapPatient, so five patients and their charts copy correctly already.

   Existing modules are topped up to five so the repository is consistent rather
   than a mix of one-patient and five-patient modules.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

/* ===========================================================================
   1. Units
   =========================================================================== */
DECLARE @Units TABLE (YearLevelName VARCHAR(50), UnitCode VARCHAR(20), SortOrder INT);

INSERT INTO @Units (YearLevelName, UnitCode, SortOrder) VALUES
    ('Year 1 Nursing', 'NURBN1104', 1),
    ('Year 1 Nursing', 'NURBN1108', 2),
    ('Year 2 Nursing', 'NURBN2104', 1),
    ('Year 2 Nursing', 'NURBN2108', 2),
    ('Year 3 Nursing', 'NURBN3104', 1),
    ('Year 3 Nursing', 'NURBN3108', 2);

/* UnitName is NOT NULL and Chelsea gave codes only, so the code doubles as the
   name until she supplies titles. Both are shown in the pickers anyway. */
INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder], [Active], [CreatedDate])
SELECT  y.[Id], u.UnitCode, u.UnitCode, u.SortOrder, 1, GETDATE()
FROM    @Units u
JOIN    [dbo].[YearLevel] y ON y.[YearLevelName] = u.YearLevelName
WHERE   NOT EXISTS (SELECT 1 FROM [dbo].[Unit] e
                    WHERE e.[YearLevelId] = y.[Id] AND e.[UnitCode] = u.UnitCode);

PRINT 'Units added: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

/* Retire the placeholders rather than delete them - modules may still point at
   one, and removing it would orphan them. */
UPDATE [dbo].[Unit]
SET    [Active] = 0
WHERE  [UnitName] LIKE '%Unassigned%' AND [Active] = 1;

PRINT 'Placeholder units deactivated: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

/* ===========================================================================
   2. InsertModule - five blank patients
   ---------------------------------------------------------------------------
   @PatientCount is a parameter rather than a hardcoded five, so the number can
   change without another migration. It defaults to five.
   =========================================================================== */
IF OBJECT_ID('[dbo].[InsertModule]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[InsertModule] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[InsertModule]
    @UnitId                INT,
    @ModuleName            VARCHAR(150),
    @Description           NVARCHAR(500) = NULL,
    @CreatedBySupervisorId INT = NULL,
    @SortOrder             INT = 0,
    @CreateBlankPatient    BIT = 1,
    @PatientCount          INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Unit] WHERE [Id] = @UnitId)
    BEGIN
        RAISERROR('Unit %d does not exist.', 16, 1, @UnitId);
        RETURN;
    END

    DECLARE @NewModuleId INT;
    DECLARE @i INT = 1;

    BEGIN TRAN;

        INSERT INTO [dbo].[Module]
            ([UnitId], [ModuleName], [Description], [SortOrder], [CreatedBySupervisorId])
        VALUES
            (@UnitId, @ModuleName, @Description, @SortOrder, @CreatedBySupervisorId);

        SET @NewModuleId = CAST(SCOPE_IDENTITY() AS INT);

        IF @CreateBlankPatient = 1
        BEGIN
            /* LabId 0 = global repository, not tied to any campus. See the
               note in CopyModule for why 0 rather than NULL.

               Numbered so an academic can tell the five apart before filling
               them in; the names are overwritten as soon as they do. */
            WHILE @i <= @PatientCount
            BEGIN
                INSERT INTO [dbo].[Patient]
                    ([FirstName], [LastName], [LabId], [ModuleId], [AdmitDate])
                VALUES
                    ('Patient', CAST(@i AS VARCHAR(10)), 0, @NewModuleId, GETDATE());

                SET @i = @i + 1;
            END
        END

    COMMIT TRAN;

    SELECT @NewModuleId AS Id;
END
GO

/* ===========================================================================
   3. Top up existing modules to five patients
   ---------------------------------------------------------------------------
   Only adds what is missing, so re-running does nothing. Modules that already
   hold five or more are left alone.
   =========================================================================== */
DECLARE @ModuleId INT, @Have INT, @Want INT = 5, @n INT;

DECLARE m CURSOR LOCAL FAST_FORWARD FOR
    SELECT  mo.[Id], COUNT(p.[Id])
    FROM    [dbo].[Module] mo
    LEFT JOIN [dbo].[Patient] p ON p.[ModuleId] = mo.[Id]
    GROUP BY mo.[Id]
    HAVING  COUNT(p.[Id]) < @Want;

OPEN m;
FETCH NEXT FROM m INTO @ModuleId, @Have;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @n = @Have + 1;
    WHILE @n <= @Want
    BEGIN
        INSERT INTO [dbo].[Patient]
            ([FirstName], [LastName], [LabId], [ModuleId], [AdmitDate])
        VALUES
            ('Patient', CAST(@n AS VARCHAR(10)), 0, @ModuleId, GETDATE());
        SET @n = @n + 1;
    END
    FETCH NEXT FROM m INTO @ModuleId, @Have;
END
CLOSE m;
DEALLOCATE m;
GO

/* ===========================================================================
   4. Confirmation
   =========================================================================== */
SELECT '1. Units by year level' AS Result_,
       y.[YearLevelName], u.[UnitCode], u.[UnitName], u.[Active]
FROM   [dbo].[Unit] u
JOIN   [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
ORDER BY y.[SortOrder], u.[Active] DESC, u.[SortOrder];

SELECT '2. Patients per module' AS Result_,
       mo.[Id] AS ModuleId, mo.[ModuleName], COUNT(p.[Id]) AS Patients
FROM   [dbo].[Module] mo
LEFT JOIN [dbo].[Patient] p ON p.[ModuleId] = mo.[Id]
GROUP BY mo.[Id], mo.[ModuleName]
ORDER BY mo.[Id];

SELECT '3. InsertModule default patient count' AS Result_,
       CASE WHEN OBJECT_DEFINITION(OBJECT_ID('dbo.InsertModule')) LIKE '%@PatientCount          INT = 5%'
            THEN '5' ELSE 'NOT SET' END AS Value_;
GO
