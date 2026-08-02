/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Requirement 1: Global Module Repository & Year-Level Management
   Part 02 of 03 - Stored procedures for the module repository

   Run order : 01_Schema  ->  02_ModuleProcs  ->  03_RescopeExistingProcs
   Idempotent: yes - every proc is DROP IF EXISTS + CREATE

   REQUIRES Part 01 to have been run first. Four procedures here reference
   Patient.ModuleId, and because dbo.Patient already exists SQL Server resolves
   its columns at CREATE time rather than deferring them. Without Part 01 those
   four fail with "Invalid column name 'ModuleId'" while the other nine are
   created successfully, leaving the repository silently half-built. The guard
   below stops the script before that can happen.
   ============================================================================ */

USE [EmrSimulator];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* ---- dependency guard: Part 01 must have run ---- */
IF (OBJECT_ID('dbo.Module') IS NULL
    OR OBJECT_ID('dbo.Unit') IS NULL
    OR OBJECT_ID('dbo.YearLevel') IS NULL
    OR COL_LENGTH('dbo.Patient', 'ModuleId') IS NULL)
BEGIN
    PRINT '';
    PRINT '********************************************************************';
    PRINT '  ABORTED - prerequisites missing.';
    PRINT '';
    PRINT '  Run Sprint3_01_ModuleRepository_Schema.sql first, then re-run';
    PRINT '  this script. Nothing has been created or modified.';
    PRINT '';
    PRINT '  Missing:';
    IF OBJECT_ID('dbo.YearLevel') IS NULL             PRINT '    - table  dbo.YearLevel';
    IF OBJECT_ID('dbo.Unit') IS NULL                  PRINT '    - table  dbo.Unit';
    IF OBJECT_ID('dbo.Module') IS NULL                PRINT '    - table  dbo.Module';
    IF COL_LENGTH('dbo.Patient','ModuleId') IS NULL   PRINT '    - column dbo.Patient.ModuleId';
    PRINT '********************************************************************';
    SET NOEXEC ON;   -- remaining batches are parsed but not executed
END
GO

/* ===========================================================================
   SECTION A - Year level and unit maintenance
   =========================================================================== */

DROP PROCEDURE IF EXISTS [dbo].[GetYearLevels];
GO
CREATE PROCEDURE [dbo].[GetYearLevels]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  y.[Id], y.[YearLevelName], y.[SortOrder], y.[Active], y.[CreatedDate],
            (SELECT COUNT(*) FROM [dbo].[Unit] u WHERE u.[YearLevelId] = y.[Id]) AS UnitCount
    FROM    [dbo].[YearLevel] y
    WHERE   (@IncludeInactive = 1 OR y.[Active] = 1)
    ORDER BY y.[SortOrder], y.[YearLevelName];
END
GO

DROP PROCEDURE IF EXISTS [dbo].[InsertYearLevel];
GO
CREATE PROCEDURE [dbo].[InsertYearLevel]
    @YearLevelName VARCHAR(50),
    @SortOrder     INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[YearLevel] ([YearLevelName], [SortOrder])
    VALUES (@YearLevelName, @SortOrder);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

DROP PROCEDURE IF EXISTS [dbo].[UpdateYearLevel];
GO
CREATE PROCEDURE [dbo].[UpdateYearLevel]
    @Id            INT,
    @YearLevelName VARCHAR(50),
    @SortOrder     INT = 0,
    @Active        BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[YearLevel]
       SET [YearLevelName] = @YearLevelName,
           [SortOrder]     = @SortOrder,
           [Active]        = @Active
     WHERE [Id] = @Id;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

DROP PROCEDURE IF EXISTS [dbo].[GetUnits];
GO
CREATE PROCEDURE [dbo].[GetUnits]
    @YearLevelId     INT = 0,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  u.[Id], u.[YearLevelId], y.[YearLevelName], u.[UnitCode], u.[UnitName],
            u.[SortOrder], u.[Active], u.[CreatedDate],
            (SELECT COUNT(*) FROM [dbo].[Module] m WHERE m.[UnitId] = u.[Id]) AS ModuleCount
    FROM    [dbo].[Unit] u
    INNER JOIN [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
    WHERE   (@YearLevelId = 0 OR u.[YearLevelId] = @YearLevelId)
      AND   (@IncludeInactive = 1 OR u.[Active] = 1)
    ORDER BY y.[SortOrder], u.[SortOrder], u.[UnitName];
END
GO

DROP PROCEDURE IF EXISTS [dbo].[InsertUnit];
GO
CREATE PROCEDURE [dbo].[InsertUnit]
    @YearLevelId INT,
    @UnitCode    VARCHAR(20) = NULL,
    @UnitName    VARCHAR(100),
    @SortOrder   INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder])
    VALUES (@YearLevelId, @UnitCode, @UnitName, @SortOrder);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

DROP PROCEDURE IF EXISTS [dbo].[UpdateUnit];
GO
CREATE PROCEDURE [dbo].[UpdateUnit]
    @Id          INT,
    @YearLevelId INT,
    @UnitCode    VARCHAR(20) = NULL,
    @UnitName    VARCHAR(100),
    @SortOrder   INT = 0,
    @Active      BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Unit]
       SET [YearLevelId] = @YearLevelId,
           [UnitCode]    = @UnitCode,
           [UnitName]    = @UnitName,
           [SortOrder]   = @SortOrder,
           [Active]      = @Active
     WHERE [Id] = @Id;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

/* ===========================================================================
   SECTION B - Module repository browse / read
   =========================================================================== */

DROP PROCEDURE IF EXISTS [dbo].[GetModules];
GO
CREATE PROCEDURE [dbo].[GetModules]
    @YearLevelId     INT = 0,
    @UnitId          INT = 0,
    @SearchTerm      VARCHAR(150) = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    /* The global repository view. Deliberately NOT filtered by LabId or
       Supervisor - every campus login sees every module. */
    SELECT  m.[Id], m.[UnitId], u.[UnitCode], u.[UnitName],
            u.[YearLevelId], y.[YearLevelName],
            m.[ModuleName], m.[Description], m.[SortOrder], m.[Active],
            m.[CreatedBySupervisorId], m.[CreatedDate], m.[UpdatedDate],
            (SELECT COUNT(*) FROM [dbo].[Patient] p WHERE p.[ModuleId] = m.[Id]) AS PatientCount
    FROM    [dbo].[Module] m
    INNER JOIN [dbo].[Unit]      u ON u.[Id] = m.[UnitId]
    INNER JOIN [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
    WHERE   (@UnitId      = 0 OR m.[UnitId]      = @UnitId)
      AND   (@YearLevelId = 0 OR u.[YearLevelId] = @YearLevelId)
      AND   (@IncludeInactive = 1 OR m.[Active] = 1)
      AND   (@SearchTerm IS NULL OR @SearchTerm = ''
             OR m.[ModuleName] LIKE '%' + @SearchTerm + '%'
             OR u.[UnitName]   LIKE '%' + @SearchTerm + '%'
             OR y.[YearLevelName] LIKE '%' + @SearchTerm + '%')
    ORDER BY y.[SortOrder], u.[SortOrder], m.[SortOrder], m.[ModuleName];
END
GO

DROP PROCEDURE IF EXISTS [dbo].[GetModuleById];
GO
CREATE PROCEDURE [dbo].[GetModuleById]
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  m.[Id], m.[UnitId], u.[UnitCode], u.[UnitName],
            u.[YearLevelId], y.[YearLevelName],
            m.[ModuleName], m.[Description], m.[SortOrder], m.[Active],
            m.[CreatedBySupervisorId], m.[CreatedDate], m.[UpdatedDate],
            (SELECT COUNT(*) FROM [dbo].[Patient] p WHERE p.[ModuleId] = m.[Id]) AS PatientCount
    FROM    [dbo].[Module] m
    INNER JOIN [dbo].[Unit]      u ON u.[Id] = m.[UnitId]
    INNER JOIN [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
    WHERE   m.[Id] = @ModuleId;
END
GO

DROP PROCEDURE IF EXISTS [dbo].[GetPatientsByModule];
GO
CREATE PROCEDURE [dbo].[GetPatientsByModule]
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM [dbo].[Patient]
    WHERE [ModuleId] = @ModuleId
    ORDER BY [LastName], [FirstName];
END
GO

/* ===========================================================================
   SECTION C - Module create / rename / delete
   =========================================================================== */

/* ---------------------------------------------------------------------------
   InsertModule
   Creates a new module and, unless suppressed, one blank Patient shell so the
   module immediately has the complete EMR structure ready to be populated.
   Clinical charts are created on demand by the existing Insert* procs, so a
   blank module legitimately has zero chart rows.
   --------------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS [dbo].[InsertModule];
GO
CREATE PROCEDURE [dbo].[InsertModule]
    @UnitId                INT,
    @ModuleName            VARCHAR(150),
    @Description           NVARCHAR(500) = NULL,
    @CreatedBySupervisorId INT = NULL,
    @SortOrder             INT = 0,
    @CreateBlankPatient    BIT = 1
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

    BEGIN TRAN;

        INSERT INTO [dbo].[Module]
            ([UnitId], [ModuleName], [Description], [SortOrder], [CreatedBySupervisorId])
        VALUES
            (@UnitId, @ModuleName, @Description, @SortOrder, @CreatedBySupervisorId);

        SET @NewModuleId = CAST(SCOPE_IDENTITY() AS INT);

        IF @CreateBlankPatient = 1
        BEGIN
            /* LabId 0 = global repository, not tied to any campus. See the
               note in CopyModule for why 0 rather than NULL. */
            INSERT INTO [dbo].[Patient]
                ([FirstName], [LastName], [LabId], [ModuleId], [AdmitDate])
            VALUES
                ('New', 'Patient', 0, @NewModuleId, GETDATE());
        END

    COMMIT TRAN;

    SELECT @NewModuleId AS Id;
END
GO

DROP PROCEDURE IF EXISTS [dbo].[UpdateModule];
GO
CREATE PROCEDURE [dbo].[UpdateModule]
    @Id          INT,
    @ModuleName  VARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @UnitId      INT = 0,
    @SortOrder   INT = 0,
    @Active      BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Module]
       SET [ModuleName]  = @ModuleName,
           [Description] = @Description,
           [UnitId]      = CASE WHEN @UnitId = 0 THEN [UnitId] ELSE @UnitId END,
           [SortOrder]   = @SortOrder,
           [Active]      = @Active,
           [UpdatedDate] = GETDATE()
     WHERE [Id] = @Id;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

/* ---------------------------------------------------------------------------
   DeleteModule
   Removes the module, its patients and every clinical row belonging to those
   patients. Children are deleted before parents throughout.
   Returns a per-table row count, matching the shape ClearPatientDataSelective
   already returns so the existing UI pattern can be reused.
   --------------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS [dbo].[DeleteModule];
GO
CREATE PROCEDURE [dbo].[DeleteModule]
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Deleted TABLE (TableName NVARCHAR(100), RowsDeleted INT);
    DECLARE @Patients TABLE (PatientId INT PRIMARY KEY);

    INSERT INTO @Patients (PatientId)
    SELECT [Id] FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId;

    BEGIN TRAN;

        /* --- child rows first ------------------------------------------- */
        DELETE e FROM [dbo].[FluidBalanceChartEntry] e
        INNER JOIN [dbo].[FluidBalanceChart] c ON c.[Id] = e.[FluidBalanceChartId]
        WHERE c.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FluidBalanceChartEntry', @@ROWCOUNT);

        DELETE i FROM [dbo].[FoodIntakeItem] i
        INNER JOIN [dbo].[FoodIntakeHeader] h ON h.[Id] = i.[HeaderId]
        WHERE h.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FoodIntakeItem', @@ROWCOUNT);

        DELETE f FROM [dbo].[RiskmanIncidentContributingFactor] f
        INNER JOIN [dbo].[RiskmanIncident] r ON r.[Id] = f.[IncidentId]
        WHERE r.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('RiskmanIncidentContributingFactor', @@ROWCOUNT);

        DELETE FROM [dbo].[IvFluidAdministration]           WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('IvFluidAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationRegularAdministration] WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationRegularAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationPrnAdministration]     WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationPrnAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[NeurologicalAdministration]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('NeurologicalAdministration', @@ROWCOUNT);

        /* --- parent chart rows ------------------------------------------ */
        DELETE FROM [dbo].[FluidBalanceChart]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FluidBalanceChart', @@ROWCOUNT);

        DELETE FROM [dbo].[FoodIntakeHeader]       WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FoodIntakeHeader', @@ROWCOUNT);

        DELETE FROM [dbo].[IvFluidChart]           WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('IvFluidChart', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationRegularChart] WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationRegularChart', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationPrnChart]     WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationPrnChart', @@ROWCOUNT);

        DELETE FROM [dbo].[NeurologicalChart]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('NeurologicalChart', @@ROWCOUNT);

        DELETE FROM [dbo].[RiskmanIncident]        WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('RiskmanIncident', @@ROWCOUNT);

        DELETE FROM [dbo].[BradenAssessment]       WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('BradenAssessment', @@ROWCOUNT);

        DELETE FROM [dbo].[FallRiskAssessments]    WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FallRiskAssessments', @@ROWCOUNT);

        DELETE FROM [dbo].[PatientAdds]            WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('PatientAdds', @@ROWCOUNT);

        DELETE FROM [dbo].[ProgressNotes]          WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('ProgressNotes', @@ROWCOUNT);

        /* --- patients, then the module itself --------------------------- */
        DELETE FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId;
        INSERT INTO @Deleted VALUES ('Patient', @@ROWCOUNT);

        DELETE FROM [dbo].[Module]  WHERE [Id] = @ModuleId;
        INSERT INTO @Deleted VALUES ('Module', @@ROWCOUNT);

    COMMIT TRAN;

    SELECT TableName, RowsDeleted FROM @Deleted WHERE RowsDeleted > 0;
END
GO

/* ===========================================================================
   SECTION D - CopyModule (deep copy)
   ---------------------------------------------------------------------------
   Duplicates a module, its patients, and every clinical chart belonging to
   those patients, remapping identity keys as it goes.

   Old -> new key mapping is captured with the MERGE ... OUTPUT idiom, because
   a plain INSERT ... OUTPUT cannot emit a column from the source row alongside
   the newly generated identity. The ON 1 = 0 predicate guarantees every source
   row falls to WHEN NOT MATCHED and is inserted.

   Each source set is spooled into a #temp table before its MERGE. Every one of
   these statements writes to the same table it reads from, and materialising
   the source first removes any question of the insert feeding back into its own
   source scan. The #temp tables are dropped automatically when the proc exits.

   KNOWN LIMITATION
   MedicationRegularChart.MedicationId and MedicationPrnChart.MedicationId
   point at dbo.Medication, which is still LabId-scoped. The copy preserves
   MedicationId as-is, so a module copied for use at another campus will
   reference that campus's formulary only if the same Medication rows exist.
   Making the formulary global is deferred to Requirement 2 (medication chart
   redesign), which reworks these tables anyway.
   =========================================================================== */

DROP PROCEDURE IF EXISTS [dbo].[CopyModule];
GO
CREATE PROCEDURE [dbo].[CopyModule]
    @SourceModuleId        INT,
    @NewModuleName         VARCHAR(150),
    @TargetUnitId          INT = 0,          -- 0 = same unit as the source
    @Description           NVARCHAR(500) = NULL,
    @CreatedBySupervisorId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Module] WHERE [Id] = @SourceModuleId)
    BEGIN
        RAISERROR('Source module %d does not exist.', 16, 1, @SourceModuleId);
        RETURN;
    END

    DECLARE @NewModuleId INT;
    DECLARE @UnitId      INT;
    DECLARE @SrcDesc     NVARCHAR(500);

    /* Module-owned rows are not tied to any campus. LabId 0 is the marker:
       dbo.Lab.Id is IDENTITY(1,1) so 0 can never match a real lab, and unlike
       NULL it is accepted by BradenAssessment, FallRiskAssessments,
       FoodIntakeHeader and RiskmanIncident, whose LabId columns are NOT NULL. */
    DECLARE @ModuleLabId INT = 0;

    SELECT @UnitId  = CASE WHEN @TargetUnitId = 0 THEN [UnitId] ELSE @TargetUnitId END,
           @SrcDesc = [Description]
    FROM   [dbo].[Module] WHERE [Id] = @SourceModuleId;

    /* old -> new key maps */
    DECLARE @MapPatient  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFbc      TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFood     TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapIvChart  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRegChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapPrnChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapNeuro    TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRiskman  TABLE (OldId INT PRIMARY KEY, NewId INT);

    BEGIN TRAN;

    /* --- 1. the module row ------------------------------------------------ */
    INSERT INTO [dbo].[Module]
        ([UnitId], [ModuleName], [Description], [SortOrder], [CreatedBySupervisorId])
    SELECT @UnitId, @NewModuleName, ISNULL(@Description, @SrcDesc), [SortOrder], @CreatedBySupervisorId
    FROM   [dbo].[Module] WHERE [Id] = @SourceModuleId;

    SET @NewModuleId = CAST(SCOPE_IDENTITY() AS INT);

    /* --- 2. patients ------------------------------------------------------ */
    SELECT * INTO #SrcPatient
    FROM [dbo].[Patient] WHERE [ModuleId] = @SourceModuleId;

    MERGE INTO [dbo].[Patient] AS tgt
    USING #SrcPatient AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([FirstName], [LastName], [DateOfBirth], [Gender], [Address], [AdmitDate],
                [Weight], [Height], [Age], [Allergy], [Intolerance], [Alerts],
                [LabId], [UriNumber], [Alert], [ModuleId])
        VALUES (src.[FirstName], src.[LastName], src.[DateOfBirth], src.[Gender], src.[Address], src.[AdmitDate],
                src.[Weight], src.[Height], src.[Age], src.[Allergy], src.[Intolerance], src.[Alerts],
                @ModuleLabId, src.[UriNumber], src.[Alert], @NewModuleId)
    OUTPUT src.[Id], inserted.[Id] INTO @MapPatient (OldId, NewId);

    /* --- 3. patient-level charts with no children ------------------------- */
    INSERT INTO [dbo].[BradenAssessment]
        ([LabId], [PatientId], [DateOfAssessment], [NurseInitials], [Sensory], [Moisture],
         [Activity], [Mobility], [Nutrition], [Friction], [TotalScore], [RiskKey], [Shift])
    SELECT @ModuleLabId, mp.NewId, s.[DateOfAssessment], s.[NurseInitials], s.[Sensory], s.[Moisture],
           s.[Activity], s.[Mobility], s.[Nutrition], s.[Friction], s.[TotalScore], s.[RiskKey], s.[Shift]
    FROM [dbo].[BradenAssessment] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[FallRiskAssessments]
        ([LabId], [PatientId], [RecentFallsScore], [MedicationsScore], [PsychologicalScore],
         [CognitiveScore], [TotalScore], [RiskLevel], [AssessedAt], [Assessor], [Notes],
         [AutoCondChange], [AutoDizziness], [AutoAnaesthetic], [InterventionNotes])
    SELECT @ModuleLabId, mp.NewId, s.[RecentFallsScore], s.[MedicationsScore], s.[PsychologicalScore],
           s.[CognitiveScore], s.[TotalScore], s.[RiskLevel], s.[AssessedAt], s.[Assessor], s.[Notes],
           s.[AutoCondChange], s.[AutoDizziness], s.[AutoAnaesthetic], s.[InterventionNotes]
    FROM [dbo].[FallRiskAssessments] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[PatientAdds]
        ([PatientId], [EnteredDate], [EnteredTime], [RespiratoryRate], [HeartRate], [Temperature],
         [Consciousness], [OxygenSaturation], [OxygenFlow], [BloodPressure], [LabId],
         [RespiratoryRateValue], [OxygenSaturationValue], [BloodPressureValue], [HeartRateValue],
         [TemperatureValue], [RespiratoryAlert], [OxygenSaturationAlert], [BloodPressureAlert],
         [HeartRateAlert], [ConsciousnessAlert], [TotalScore], [BloodPressureDiastolicValue],
         [BloodPressureDiastolic])
    SELECT mp.NewId, s.[EnteredDate], s.[EnteredTime], s.[RespiratoryRate], s.[HeartRate], s.[Temperature],
           s.[Consciousness], s.[OxygenSaturation], s.[OxygenFlow], s.[BloodPressure], @ModuleLabId,
           s.[RespiratoryRateValue], s.[OxygenSaturationValue], s.[BloodPressureValue], s.[HeartRateValue],
           s.[TemperatureValue], s.[RespiratoryAlert], s.[OxygenSaturationAlert], s.[BloodPressureAlert],
           s.[HeartRateAlert], s.[ConsciousnessAlert], s.[TotalScore], s.[BloodPressureDiastolicValue],
           s.[BloodPressureDiastolic]
    FROM [dbo].[PatientAdds] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[ProgressNotes]
        ([LabId], [Notes], [Sign], [NotesDate], [PatientId], [NotesFrom])
    SELECT @ModuleLabId, s.[Notes], s.[Sign], s.[NotesDate], mp.NewId, s.[NotesFrom]
    FROM [dbo].[ProgressNotes] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 4. fluid balance chart + entries --------------------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcFbc
    FROM [dbo].[FluidBalanceChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[FluidBalanceChart] AS tgt
    USING #SrcFbc AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [ChartDate], [ChartTime], [PreviousDayBalance],
                [TotalIntake], [TotalOutput], [Balance], [TotalBalance], [ClinicalNotes],
                [SignatureData], [CreatedDateTime], [UpdatedDateTime])
        VALUES (@ModuleLabId, src.NewPatientId, src.[ChartDate], src.[ChartTime], src.[PreviousDayBalance],
                src.[TotalIntake], src.[TotalOutput], src.[Balance], src.[TotalBalance], src.[ClinicalNotes],
                src.[SignatureData], src.[CreatedDateTime], src.[UpdatedDateTime])
    OUTPUT src.[Id], inserted.[Id] INTO @MapFbc (OldId, NewId);

    INSERT INTO [dbo].[FluidBalanceChartEntry]
        ([FluidBalanceChartId], [EntryTime], [EntryType], [Category], [AmountMl],
         [CreatedDateTime], [EntryDate], [Initials])
    SELECT mf.NewId, s.[EntryTime], s.[EntryType], s.[Category], s.[AmountMl],
           s.[CreatedDateTime], s.[EntryDate], s.[Initials]
    FROM [dbo].[FluidBalanceChartEntry] s
    INNER JOIN @MapFbc mf ON mf.OldId = s.[FluidBalanceChartId];

    /* --- 5. food intake header + items ------------------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcFood
    FROM [dbo].[FoodIntakeHeader] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[FoodIntakeHeader] AS tgt
    USING #SrcFood AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [DayText], [IntakeDate],
                [Shift1Signature], [Shift1Designation], [Shift2Signature], [Shift2Designation],
                [Shift3Signature], [Shift3Designation], [BreakfastComment], [MorningTeaComment],
                [LunchComment], [AfternoonTeaComment], [DinnerComment], [SupperComment])
        VALUES (@ModuleLabId, src.NewPatientId, src.[DayText], src.[IntakeDate],
                src.[Shift1Signature], src.[Shift1Designation], src.[Shift2Signature], src.[Shift2Designation],
                src.[Shift3Signature], src.[Shift3Designation], src.[BreakfastComment], src.[MorningTeaComment],
                src.[LunchComment], src.[AfternoonTeaComment], src.[DinnerComment], src.[SupperComment])
    OUTPUT src.[Id], inserted.[Id] INTO @MapFood (OldId, NewId);

    INSERT INTO [dbo].[FoodIntakeItem] ([HeaderId], [Meal], [Label], [Notes], [Amount])
    SELECT mh.NewId, s.[Meal], s.[Label], s.[Notes], s.[Amount]
    FROM [dbo].[FoodIntakeItem] s
    INNER JOIN @MapFood mh ON mh.OldId = s.[HeaderId];

    /* --- 6. IV fluid chart + administrations ------------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcIvChart
    FROM [dbo].[IvFluidChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[IvFluidChart] AS tgt
    USING #SrcIvChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [Date], [FlaskVol], [Strength], [Rate], [Dose], [OfficerSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[Date], src.[FlaskVol], src.[Strength], src.[Rate], src.[Dose], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapIvChart (OldId, NewId);

    INSERT INTO [dbo].[IvFluidAdministration]
        ([LabId], [PatientId], [IvFluidChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [VolGiven], [PharmacistReview], [NurseSign], [CoSign])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
           s.[VolGiven], s.[PharmacistReview], s.[NurseSign], s.[CoSign]
    FROM [dbo].[IvFluidAdministration] s
    INNER JOIN @MapIvChart mc ON mc.OldId = s.[IvFluidChartId]
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 7. regular medication chart + administrations -------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcRegChart
    FROM [dbo].[MedicationRegularChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[MedicationRegularChart] AS tgt
    USING #SrcRegChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [MedicationId], [Dose], [DoseFrequency], [DoseDate], [DoseTime],
                [Indication], [Route], [Pharmacy], [Prescriber], [PrescriberSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRegChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationRegularAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
           s.[StudentSign], s.[Reason], s.[CoSign], s.[Dose]
    FROM [dbo].[MedicationRegularAdministration] s
    INNER JOIN @MapRegChart mc ON mc.OldId = s.[PatientMedicationChartId]
    INNER JOIN @MapPatient  mp ON mp.OldId = s.[PatientId];

    /* --- 8. PRN medication chart + administrations ------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcPrnChart
    FROM [dbo].[MedicationPrnChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[MedicationPrnChart] AS tgt
    USING #SrcPrnChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [MedicationId], [Dose], [DoseFrequency], [DoseDate], [DoseTime],
                [Indication], [Route], [Pharmacy], [Prescriber], [PrescriberSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapPrnChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationPrnAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
           s.[StudentSign], s.[Reason], s.[CoSign], s.[Dose]
    FROM [dbo].[MedicationPrnAdministration] s
    INNER JOIN @MapPrnChart mc ON mc.OldId = s.[PatientMedicationChartId]
    INNER JOIN @MapPatient  mp ON mp.OldId = s.[PatientId];

    /* --- 9. neurological chart + administrations -------------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcNeuro
    FROM [dbo].[NeurologicalChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[NeurologicalChart] AS tgt
    USING #SrcNeuro AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [Date], [Time], [EyesOpenScore], [VerbalResponseScore],
                [MotorResponseScore], [TotalComaScale], [EndotrachealTube], [RightPupilSize],
                [RightPupilReaction], [LeftPupilSize], [LeftPupilReaction], [RightArmResponse],
                [RightLegResponse], [LeftArmResponse], [LeftLegResponse], [OfficerSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[Date], src.[Time], src.[EyesOpenScore], src.[VerbalResponseScore],
                src.[MotorResponseScore], src.[TotalComaScale], src.[EndotrachealTube], src.[RightPupilSize],
                src.[RightPupilReaction], src.[LeftPupilSize], src.[LeftPupilReaction], src.[RightArmResponse],
                src.[RightLegResponse], src.[LeftArmResponse], src.[LeftLegResponse], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapNeuro (OldId, NewId);

    INSERT INTO [dbo].[NeurologicalAdministration]
        ([LabId], [PatientId], [NeurologicalChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [PharmacistReview], [NurseSign], [CoSign])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
           s.[PharmacistReview], s.[NurseSign], s.[CoSign]
    FROM [dbo].[NeurologicalAdministration] s
    INNER JOIN @MapNeuro   mc ON mc.OldId = s.[NeurologicalChartId]
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 10. riskman incident + contributing factors ---------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcRiskman
    FROM [dbo].[RiskmanIncident] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[RiskmanIncident] AS tgt
    USING #SrcRiskman AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [IncidentDate], [IncidentTime], [URINumber], [Campus],
                [WardLocationType], [PersonName], [DateOfBirth], [Sex], [IndigenousStatus],
                [BriefSummary], [Details], [EventType], [EventSubType], [IsClinicalIncident],
                [ClinicalHarmLevel], [HarmDuration], [RequiredCareLevelClinical],
                [EmergencyResponseType], [EmergencyResponseOutcome], [ContributingAdditionalDetail],
                [ReporterIsAffectedStaff], [OhsTypeOfInjury], [OhsTypeOfInjuryOther],
                [OhsBodyPartAffected], [OhsBodyPartOther], [OhsLevelOfHarmSustained],
                [OhsRequiredLevelOfCare], [OhsActionsRequired], [nextOfKinNotifiedDate],
                [nextOfKinNotifiedTime], [SignedBy], [SignedDate], [Apse])
        VALUES (@ModuleLabId, src.NewPatientId, src.[IncidentDate], src.[IncidentTime], src.[URINumber], src.[Campus],
                src.[WardLocationType], src.[PersonName], src.[DateOfBirth], src.[Sex], src.[IndigenousStatus],
                src.[BriefSummary], src.[Details], src.[EventType], src.[EventSubType], src.[IsClinicalIncident],
                src.[ClinicalHarmLevel], src.[HarmDuration], src.[RequiredCareLevelClinical],
                src.[EmergencyResponseType], src.[EmergencyResponseOutcome], src.[ContributingAdditionalDetail],
                src.[ReporterIsAffectedStaff], src.[OhsTypeOfInjury], src.[OhsTypeOfInjuryOther],
                src.[OhsBodyPartAffected], src.[OhsBodyPartOther], src.[OhsLevelOfHarmSustained],
                src.[OhsRequiredLevelOfCare], src.[OhsActionsRequired], src.[nextOfKinNotifiedDate],
                src.[nextOfKinNotifiedTime], src.[SignedBy], src.[SignedDate], src.[Apse])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRiskman (OldId, NewId);

    INSERT INTO [dbo].[RiskmanIncidentContributingFactor] ([IncidentId], [FactorCode])
    SELECT mr.NewId, s.[FactorCode]
    FROM [dbo].[RiskmanIncidentContributingFactor] s
    INNER JOIN @MapRiskman mr ON mr.OldId = s.[IncidentId];

    COMMIT TRAN;

    SELECT @NewModuleId AS Id;
END
GO

PRINT '=== Sprint3 Part 02 (Module procs) complete ===';
GO

/* Clear the guard so the session is left usable either way. */
SET NOEXEC OFF;
GO
