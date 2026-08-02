/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Task 3: ADDS chart oxygen fields
   Task 4: Progress note date and time

   RUN AFTER Sprint3_01 .. Sprint3_05.

   Sprint3_03 re-created InsertPatientAdds and GetProgressNotes without the
   changes below, so this script must run after it. If Sprint3_03 is ever
   re-run, run this one again afterwards.

   WHAT THIS DOES
   ---------------------------------------------------------------------------
   TASK 3 - Naomi's requirement:
       "The 'oxygen flow rate' field needs a 'N/A' option added.
        Add a 'Mode of Delivery' option under the 'oxygen flow rate' field.
        The options ... Room Air (RA), Intra Nasal Cannula (INC), Hudson Mask (HM)"

       N/A needs no schema change - OxygenFlow is varchar(20) and stores the
       literal 'N/A'. Mode of Delivery is a new column.

   TASK 4 - Naomi's requirement:
       "A selectable date ... a selectable time when creating a progress note.
        The recorded date and time to be displayed when viewing progress notes.
        The 'delete' option ... removed from the student login and an 'edit'
        field option enabled"

       The date and time already fit in ProgressNotes.NotesDate (datetime), so
       no schema change. Three procedure changes are needed:

       1. UpdateProgressNote declares @Notes VARCHAR(500) while the column is
          TEXT. Nobody could reach that path before because there was no edit
          screen; now that edit is enabled, a note over 500 characters would be
          silently truncated on save. Widened to VARCHAR(MAX).

       2. GetProgressNotes ordered by NotesFrom DESC, which is the author's
          role, not a time. Every note from a supervisor sorted above every
          note from a student regardless of when it was written, and notes
          written before the role was recorded have NotesFrom NULL. Now orders
          newest first, which is what the wireframe asks for.

       3. GetProgressNoteById is new. Edit needs to load one note, and the
          server needs to read a note's author before allowing an edit or a
          delete, so students cannot alter a supervisor's note by posting an id
          directly.

   IDEMPOTENT. Safe to re-run.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

/* ===========================================================================
   1. SCHEMA - PatientAdds.ModeOfDelivery
   ---------------------------------------------------------------------------
   NULL-able on purpose. Every ADDS observation recorded before this sprint has
   no mode of delivery and there is no clinically safe value to invent for it.
   varchar(50) holds the longest option, 'Intra Nasal Cannula (INC)' (25).
   =========================================================================== */
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('[dbo].[PatientAdds]')
      AND name = 'ModeOfDelivery')
BEGIN
    ALTER TABLE [dbo].[PatientAdds] ADD [ModeOfDelivery] VARCHAR(50) NULL;
    PRINT 'Added PatientAdds.ModeOfDelivery';
END
ELSE
    PRINT 'PatientAdds.ModeOfDelivery already present - skipped';
GO

/* ===========================================================================
   2. InsertPatientAdds - carry ModeOfDelivery
   ---------------------------------------------------------------------------
   Based on the Sprint3_03 version, which is the one currently deployed. The
   LabId predicate stays as Sprint3_03 left it so module patients still match.
   =========================================================================== */
IF OBJECT_ID('[dbo].[InsertPatientAdds]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[InsertPatientAdds] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[InsertPatientAdds]
    @PatientId INT,
    @LabId INT,
    @EnteredDate DATE,
    @EnteredTime VARCHAR(20),
    @RespiratoryRate VARCHAR(20) = NULL,
    @HeartRate VARCHAR(20) = NULL,
    @Temperature VARCHAR(20) = NULL,
    @Consciousness VARCHAR(50) = NULL,
    @OxygenSaturation VARCHAR(20) = NULL,
    @OxygenFlow VARCHAR(20) = NULL,
    @ModeOfDelivery VARCHAR(50) = NULL,
    @BloodPressure VARCHAR(20) = NULL,
    @BloodPressureDiastolic VARCHAR(20) = NULL,

    @RespiratoryRateValue INT = NULL,
    @OxygenSaturationValue INT = NULL,
    @BloodPressureValue INT = NULL,
    @BloodPressureDiastolicValue INT = NULL,
    @HeartRateValue INT = NULL,
    @TemperatureValue INT = NULL,

    @RespiratoryAlert INT = NULL,
    @OxygenSaturationAlert INT = NULL,
    @BloodPressureAlert INT = NULL,
    @HeartRateAlert INT = NULL,
    @ConsciousnessAlert INT = NULL,
    @TotalScore INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@RespiratoryAlert = 1 OR @OxygenSaturationAlert = 1 OR @BloodPressureAlert = 1 OR @HeartRateAlert = 1 OR @ConsciousnessAlert = 1)
    BEGIN
        UPDATE Patient SET Alert = 1
        WHERE Id = @PatientId AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    END

    INSERT INTO PatientAdds
        (PatientId, LabId, EnteredDate, EnteredTime, RespiratoryRate, HeartRate, Temperature, Consciousness,
         OxygenSaturation, OxygenFlow, ModeOfDelivery, BloodPressure, BloodPressureDiastolic,
         RespiratoryRateValue, OxygenSaturationValue, BloodPressureValue, BloodPressureDiastolicValue,
         HeartRateValue, TemperatureValue,
         RespiratoryAlert, OxygenSaturationAlert, BloodPressureAlert, HeartRateAlert, ConsciousnessAlert, TotalScore)
    VALUES
        (@PatientId, @LabId, @EnteredDate, @EnteredTime, @RespiratoryRate, @HeartRate, @Temperature, @Consciousness,
         @OxygenSaturation, @OxygenFlow, @ModeOfDelivery, @BloodPressure, @BloodPressureDiastolic,
         @RespiratoryRateValue, @OxygenSaturationValue, @BloodPressureValue, @BloodPressureDiastolicValue,
         @HeartRateValue, @TemperatureValue,
         @RespiratoryAlert, @OxygenSaturationAlert, @BloodPressureAlert, @HeartRateAlert, @ConsciousnessAlert, @TotalScore);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

/* ===========================================================================
   3. UpdatePatientAdds - carry ModeOfDelivery
   ---------------------------------------------------------------------------
   Left out of Sprint3_03 because "SET LabId = @LabId" there is a column
   assignment, not a filter, so the module re-scope did not apply. This is the
   original definition with the new column added.
   =========================================================================== */
IF OBJECT_ID('[dbo].[UpdatePatientAdds]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[UpdatePatientAdds] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[UpdatePatientAdds]
    @Id INT = 0,
    @PatientId INT,
    @LabId INT,
    @RespiratoryRate VARCHAR(20) = NULL,
    @HeartRate VARCHAR(20) = NULL,
    @Temperature VARCHAR(20) = NULL,
    @Consciousness VARCHAR(50) = NULL,
    @OxygenSaturation VARCHAR(20) = NULL,
    @OxygenFlow VARCHAR(20) = NULL,
    @ModeOfDelivery VARCHAR(50) = NULL,
    @BloodPressure VARCHAR(20) = NULL,
    @BloodPressureDiastolic VARCHAR(20) = NULL,

    @RespiratoryRateValue INT = NULL,
    @OxygenSaturationValue INT = NULL,
    @BloodPressureValue INT = NULL,
    @BloodPressureDiastolicValue INT = NULL,
    @HeartRateValue INT = NULL,
    @TemperatureValue INT = NULL,

    @RespiratoryAlert INT = NULL,
    @OxygenSaturationAlert INT = NULL,
    @BloodPressureAlert INT = NULL,
    @HeartRateAlert INT = NULL,
    @ConsciousnessAlert INT = NULL,
    @TotalScore INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE PatientAdds
    SET
        PatientId = @PatientId,
        LabId = @LabId,
        RespiratoryRate = @RespiratoryRate,
        HeartRate = @HeartRate,
        Temperature = @Temperature,
        Consciousness = @Consciousness,
        OxygenSaturation = @OxygenSaturation,
        OxygenFlow = @OxygenFlow,
        ModeOfDelivery = @ModeOfDelivery,
        BloodPressure = @BloodPressure,
        BloodPressureDiastolic = @BloodPressureDiastolic,
        ConsciousnessAlert = @ConsciousnessAlert,
        TotalScore = @TotalScore
    WHERE Id = @Id

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No record found with the given Id.', 16, 1);
    END
END
GO

/* ===========================================================================
   4. UpdateProgressNote - stop truncating long notes
   ---------------------------------------------------------------------------
   ProgressNotes.Notes is TEXT but the parameter was VARCHAR(500). Enabling the
   edit screen makes that reachable: a student writes a 900 character note,
   opens it to correct a typo, saves, and loses 400 characters with no error.
   VARCHAR(MAX) assigns to a TEXT column without truncation.

   Everything else is unchanged from the original definition.
   =========================================================================== */
IF OBJECT_ID('[dbo].[UpdateProgressNote]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[UpdateProgressNote] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[UpdateProgressNote]
    @Id INT,
    @LabId INT = NULL,
    @Notes VARCHAR(MAX) = NULL,
    @Sign VARCHAR(50) = NULL,
    @NotesDate DATETIME = NULL,
    @PatientId INT = NULL,
    @NotesFrom VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ProgressNotes
    SET
        LabId = @LabId,
        Notes = @Notes,
        Sign = @Sign,
        NotesDate = @NotesDate,
        PatientId = @PatientId,
        NotesFrom = @NotesFrom
    WHERE Id = @Id;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No record found with the given Id.', 16, 1);
    END
END
GO

/* ===========================================================================
   5. GetProgressNotes - newest first
   ---------------------------------------------------------------------------
   Keeps the Sprint3_03 module predicate. Only the ORDER BY changes.
   Id is the tie-break so two notes saved in the same minute keep a stable
   order, and rows with a NULL NotesDate sort last rather than first.
   =========================================================================== */
IF OBJECT_ID('[dbo].[GetProgressNotes]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetProgressNotes] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetProgressNotes]
    @LabId INT = NULL,
    @PatientId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, LabId, Notes, Sign, NotesDate, PatientId, NotesFrom
    FROM ProgressNotes
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
      AND PatientId = @PatientId
    ORDER BY CASE WHEN NotesDate IS NULL THEN 1 ELSE 0 END,
             NotesDate DESC,
             Id DESC;
END
GO

/* ===========================================================================
   6. GetProgressNoteById - new
   ---------------------------------------------------------------------------
   Used by the edit screen to load one note, and by the server to check who
   wrote a note before permitting an edit or a delete.

   Deliberately not filtered by LabId. The caller has the id and the server
   compares NotesFrom itself; adding a LabId filter here would make the check
   return "not found" for a module note and silently allow the action.
   =========================================================================== */
IF OBJECT_ID('[dbo].[GetProgressNoteById]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetProgressNoteById] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetProgressNoteById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, LabId, Notes, Sign, NotesDate, PatientId, NotesFrom
    FROM ProgressNotes
    WHERE Id = @Id;
END
GO

/* ===========================================================================
   7. CopyModule - carry ModeOfDelivery through a module copy
   ---------------------------------------------------------------------------
   CopyModule lists the PatientAdds columns explicitly rather than using
   SELECT *, so a column added afterwards is silently dropped: copy a module
   and every observation comes back with a blank mode of delivery, with no
   error to show for it.

   It has to be re-emitted here rather than fixed in Sprint3_02. Sprint3_02
   runs before the column exists, and SQL Server validates column references
   against tables that already exist at CREATE PROCEDURE time, so naming
   ModeOfDelivery there would fail outright.

   This is the Sprint3_02 definition with [ModeOfDelivery] added to the
   PatientAdds insert - two lines - and nothing else changed.
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
         [Consciousness], [OxygenSaturation], [OxygenFlow], [ModeOfDelivery], [BloodPressure], [LabId],
         [RespiratoryRateValue], [OxygenSaturationValue], [BloodPressureValue], [HeartRateValue],
         [TemperatureValue], [RespiratoryAlert], [OxygenSaturationAlert], [BloodPressureAlert],
         [HeartRateAlert], [ConsciousnessAlert], [TotalScore], [BloodPressureDiastolicValue],
         [BloodPressureDiastolic])
    SELECT mp.NewId, s.[EnteredDate], s.[EnteredTime], s.[RespiratoryRate], s.[HeartRate], s.[Temperature],
           s.[Consciousness], s.[OxygenSaturation], s.[OxygenFlow], s.[ModeOfDelivery], s.[BloodPressure], @ModuleLabId,
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

/* ===========================================================================
   8. Confirmation
   =========================================================================== */
SELECT 'Column' AS Object_,
       'PatientAdds.ModeOfDelivery' AS Name_,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns
                         WHERE object_id = OBJECT_ID('[dbo].[PatientAdds]')
                           AND name = 'ModeOfDelivery')
            THEN 'present' ELSE 'MISSING' END AS Status_
UNION ALL
SELECT 'Procedure', p.Name_,
       CASE WHEN OBJECT_ID('[dbo].[' + p.Name_ + ']', 'P') IS NULL THEN 'MISSING' ELSE 'present' END
FROM (VALUES ('InsertPatientAdds'), ('UpdatePatientAdds'), ('UpdateProgressNote'),
             ('GetProgressNotes'), ('GetProgressNoteById'), ('CopyModule')) AS p(Name_)
UNION ALL
SELECT 'Parameter', 'InsertPatientAdds.@ModeOfDelivery',
       CASE WHEN EXISTS (SELECT 1 FROM sys.parameters
                         WHERE object_id = OBJECT_ID('[dbo].[InsertPatientAdds]')
                           AND name = '@ModeOfDelivery')
            THEN 'present' ELSE 'MISSING' END
UNION ALL
SELECT 'Parameter', 'UpdatePatientAdds.@ModeOfDelivery',
       CASE WHEN EXISTS (SELECT 1 FROM sys.parameters
                         WHERE object_id = OBJECT_ID('[dbo].[UpdatePatientAdds]')
                           AND name = '@ModeOfDelivery')
            THEN 'present' ELSE 'MISSING' END
UNION ALL
SELECT 'Copy', 'CopyModule carries ModeOfDelivery',
       CASE WHEN OBJECT_DEFINITION(OBJECT_ID('[dbo].[CopyModule]')) LIKE '%ModeOfDelivery%'
            THEN 'yes' ELSE 'NO - re-run section 7' END;
GO
