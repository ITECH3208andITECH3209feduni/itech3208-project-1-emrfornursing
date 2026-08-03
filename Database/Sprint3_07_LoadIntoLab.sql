/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Load a module into a lab  (Naomi's "Option B" - module as master copy)

   RUN AFTER Sprint3_01 .. Sprint3_06.

   WHAT THIS IS FOR
   ---------------------------------------------------------------------------
   An academic prepares "Week 2 - Post-operative care" once, as a module. Before
   Tuesday's class they load it into their campus lab. Students work on that
   copy. Before Thursday's class they load it again, which replaces Tuesday's
   copy with the original setup. The module itself is never touched.

   Because each campus loads into its own lab, Berwick and Gippsland can run the
   same scenario in the same week without seeing each other's entries.

   HOW A LAB COPY IS IDENTIFIED
   ---------------------------------------------------------------------------
   Three columns on dbo.Patient tell the three kinds of patient apart:

       LabId   ModuleId   SourceModuleId   what it is
       -----   --------   --------------   --------------------------------
       <lab>   NULL       NULL             an ordinary campus patient
       0       <module>   NULL             the module's own master patient
       <lab>   NULL       <module>         a lab copy loaded from a module

   SourceModuleId is what makes reloading safe. Without it the only way to reset
   a lab would be to clear the whole lab, which would take out every unrelated
   patient the campus had set up. With it, a reload replaces exactly one patient
   and leaves everything else alone.

   NO FOREIGN KEY ON SourceModuleId - DELIBERATE
   ---------------------------------------------------------------------------
   Lab copies are not deleted when their module is deleted, so a foreign key
   would block DeleteModule for any module that had ever been loaded into a lab.
   Students' work should not stop an academic tidying the repository. Deleting a
   module leaves its lab copies in place as ordinary patients that can no longer
   be reloaded. An index is added instead, which is what the lookup needs.

   IDEMPOTENT. Safe to re-run.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

/* ===========================================================================
   1. SCHEMA - Patient.SourceModuleId and Patient.LoadedIntoLabAt
   =========================================================================== */
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.Patient') AND name = 'SourceModuleId')
BEGIN
    ALTER TABLE [dbo].[Patient] ADD [SourceModuleId] INT NULL;
    PRINT 'Added dbo.Patient.SourceModuleId';
END
ELSE
    PRINT 'dbo.Patient.SourceModuleId already exists - skipped';
GO

/* When the copy was taken, so the repository can show "loaded 2 hours ago" and
   an academic can tell at a glance whether the lab holds this week's setup. */
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.Patient') AND name = 'LoadedIntoLabAt')
BEGIN
    ALTER TABLE [dbo].[Patient] ADD [LoadedIntoLabAt] DATETIME NULL;
    PRINT 'Added dbo.Patient.LoadedIntoLabAt';
END
ELSE
    PRINT 'dbo.Patient.LoadedIntoLabAt already exists - skipped';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Patient_SourceModuleId_LabId'
                 AND object_id = OBJECT_ID('dbo.Patient'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Patient_SourceModuleId_LabId]
        ON [dbo].[Patient]([SourceModuleId] ASC, [LabId] ASC);
    PRINT 'Created index IX_Patient_SourceModuleId_LabId';
END
ELSE
    PRINT 'Index IX_Patient_SourceModuleId_LabId already exists - skipped';
GO

/* ===========================================================================
   2. LoadModuleIntoLab
   ---------------------------------------------------------------------------
   Generated from CopyModule rather than written by hand. The chart copying is
   character for character the same as the CopyModule in Sprint3_06 - the
   current definition, not the original in Sprint3_02 - with @ModuleLabId replaced by
   @LabId in all 15 places it appears, so the two procedures cannot drift in
   what they copy. The differences are only:

     - no Module row is created
     - the new patient gets LabId = @LabId, ModuleId = NULL, SourceModuleId
     - any previous copy of this module in this lab is removed first

   THIS DESTROYS STUDENT WORK BY DESIGN. Reloading is how an academic resets a
   scenario between classes, so anything students wrote into the previous copy
   is deleted. The count of removed rows is returned so the UI can say what went.
   =========================================================================== */
IF OBJECT_ID('[dbo].[LoadModuleIntoLab]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[LoadModuleIntoLab];
GO
CREATE PROCEDURE [dbo].[LoadModuleIntoLab]
    @ModuleId INT,
    @LabId    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Module] WHERE [Id] = @ModuleId)
    BEGIN
        RAISERROR('Module %d does not exist.', 16, 1, @ModuleId);
        RETURN;
    END

    /* Guard against loading into the module scope itself. LabId 0 is the marker
       for module-owned rows, so a copy taken with LabId 0 would be
       indistinguishable from the master and would corrupt the repository. */
    IF ISNULL(@LabId, 0) = 0
    BEGIN
        RAISERROR('A module must be loaded into a real lab. LabId 0 is reserved for the repository itself.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId)
    BEGIN
        RAISERROR('Module %d has no patient to load. Populate it first.', 16, 1, @ModuleId);
        RETURN;
    END

    DECLARE @Deleted  TABLE (TableName NVARCHAR(100), RowsDeleted INT);
    DECLARE @Patients TABLE (PatientId INT PRIMARY KEY);

    /* old -> new key maps */
    DECLARE @MapPatient  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFbc      TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFood     TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapIvChart  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRegChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapPrnChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapNeuro    TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRiskman  TABLE (OldId INT PRIMARY KEY, NewId INT);

    /* The previous copy of THIS module in THIS lab, and nothing else. Ordinary
       campus patients have SourceModuleId NULL and are never matched. */
    INSERT INTO @Patients (PatientId)
    SELECT [Id] FROM [dbo].[Patient]
    WHERE [SourceModuleId] = @ModuleId AND [LabId] = @LabId;

    DECLARE @ReplacedPatientCount INT = (SELECT COUNT(*) FROM @Patients);

    BEGIN TRAN;

        /* --- 1. remove the previous copy, if there is one ------------------ */
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

        DELETE FROM [dbo].[Patient]
        WHERE [Id] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('Patient', @@ROWCOUNT);

        /* --- 2. the patient ------------------------------------------------ */
        SELECT * INTO #SrcPatient
        FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId;

        MERGE INTO [dbo].[Patient] AS tgt
        USING #SrcPatient AS src
           ON 1 = 0
        WHEN NOT MATCHED THEN
            INSERT ([FirstName], [LastName], [DateOfBirth], [Gender], [Address], [AdmitDate],
                    [Weight], [Height], [Age], [Allergy], [Intolerance], [Alerts],
                    [LabId], [UriNumber], [Alert], [ModuleId], [SourceModuleId], [LoadedIntoLabAt])
            VALUES (src.[FirstName], src.[LastName], src.[DateOfBirth], src.[Gender], src.[Address], src.[AdmitDate],
                    src.[Weight], src.[Height], src.[Age], src.[Allergy], src.[Intolerance], src.[Alerts],
                    @LabId, src.[UriNumber], src.[Alert], NULL, @ModuleId, GETDATE())
        OUTPUT src.[Id], inserted.[Id] INTO @MapPatient (OldId, NewId);

        /* --- 3. the charts, generated from the CopyModule in Sprint3_06 ------ */
    INSERT INTO [dbo].[BradenAssessment]
        ([LabId], [PatientId], [DateOfAssessment], [NurseInitials], [Sensory], [Moisture],
         [Activity], [Mobility], [Nutrition], [Friction], [TotalScore], [RiskKey], [Shift])
    SELECT @LabId, mp.NewId, s.[DateOfAssessment], s.[NurseInitials], s.[Sensory], s.[Moisture],
           s.[Activity], s.[Mobility], s.[Nutrition], s.[Friction], s.[TotalScore], s.[RiskKey], s.[Shift]
    FROM [dbo].[BradenAssessment] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[FallRiskAssessments]
        ([LabId], [PatientId], [RecentFallsScore], [MedicationsScore], [PsychologicalScore],
         [CognitiveScore], [TotalScore], [RiskLevel], [AssessedAt], [Assessor], [Notes],
         [AutoCondChange], [AutoDizziness], [AutoAnaesthetic], [InterventionNotes])
    SELECT @LabId, mp.NewId, s.[RecentFallsScore], s.[MedicationsScore], s.[PsychologicalScore],
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
           s.[Consciousness], s.[OxygenSaturation], s.[OxygenFlow], s.[ModeOfDelivery], s.[BloodPressure], @LabId,
           s.[RespiratoryRateValue], s.[OxygenSaturationValue], s.[BloodPressureValue], s.[HeartRateValue],
           s.[TemperatureValue], s.[RespiratoryAlert], s.[OxygenSaturationAlert], s.[BloodPressureAlert],
           s.[HeartRateAlert], s.[ConsciousnessAlert], s.[TotalScore], s.[BloodPressureDiastolicValue],
           s.[BloodPressureDiastolic]
    FROM [dbo].[PatientAdds] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[ProgressNotes]
        ([LabId], [Notes], [Sign], [NotesDate], [PatientId], [NotesFrom])
    SELECT @LabId, s.[Notes], s.[Sign], s.[NotesDate], mp.NewId, s.[NotesFrom]
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
        VALUES (@LabId, src.NewPatientId, src.[ChartDate], src.[ChartTime], src.[PreviousDayBalance],
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
        VALUES (@LabId, src.NewPatientId, src.[DayText], src.[IntakeDate],
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
        VALUES (@LabId, src.NewPatientId, src.[Date], src.[FlaskVol], src.[Strength], src.[Rate], src.[Dose], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapIvChart (OldId, NewId);

    INSERT INTO [dbo].[IvFluidAdministration]
        ([LabId], [PatientId], [IvFluidChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [VolGiven], [PharmacistReview], [NurseSign], [CoSign])
    SELECT @LabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
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
        VALUES (@LabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRegChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationRegularAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @LabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
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
        VALUES (@LabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapPrnChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationPrnAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @LabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
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
        VALUES (@LabId, src.NewPatientId, src.[Date], src.[Time], src.[EyesOpenScore], src.[VerbalResponseScore],
                src.[MotorResponseScore], src.[TotalComaScale], src.[EndotrachealTube], src.[RightPupilSize],
                src.[RightPupilReaction], src.[LeftPupilSize], src.[LeftPupilReaction], src.[RightArmResponse],
                src.[RightLegResponse], src.[LeftArmResponse], src.[LeftLegResponse], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapNeuro (OldId, NewId);

    INSERT INTO [dbo].[NeurologicalAdministration]
        ([LabId], [PatientId], [NeurologicalChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [PharmacistReview], [NurseSign], [CoSign])
    SELECT @LabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
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
        VALUES (@LabId, src.NewPatientId, src.[IncidentDate], src.[IncidentTime], src.[URINumber], src.[Campus],
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

    SELECT
        (SELECT TOP 1 NewId FROM @MapPatient)        AS PatientId,
        @ModuleId                                    AS ModuleId,
        @LabId                                       AS LabId,
        @ReplacedPatientCount                        AS ReplacedExistingCopy,
        (SELECT ISNULL(SUM(RowsDeleted), 0) FROM @Deleted) AS RowsRemoved;
END
GO

/* ===========================================================================
   3. GetLabModuleLoads
   ---------------------------------------------------------------------------
   Which modules are currently loaded into a lab, and when. Drives the "loaded"
   badge in the module repository so an academic can see at a glance whether
   the lab already holds this week's scenario.
   =========================================================================== */
IF OBJECT_ID('[dbo].[GetLabModuleLoads]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetLabModuleLoads] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetLabModuleLoads]
    @LabId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  p.[SourceModuleId]  AS ModuleId,
            p.[Id]              AS PatientId,
            p.[FirstName],
            p.[LastName],
            p.[LoadedIntoLabAt],
            m.[ModuleName]
    FROM    [dbo].[Patient] p
    LEFT JOIN [dbo].[Module] m ON m.[Id] = p.[SourceModuleId]
    WHERE   p.[LabId] = @LabId
      AND   p.[SourceModuleId] IS NOT NULL;
END
GO

/* ===========================================================================
   4. Confirmation
   =========================================================================== */
SELECT 'Column' AS Object_, c.Name_ AS Name_,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns
                         WHERE object_id = OBJECT_ID('dbo.Patient') AND name = c.Name_)
            THEN 'present' ELSE 'MISSING' END AS Status_
FROM (VALUES ('SourceModuleId'), ('LoadedIntoLabAt')) AS c(Name_)
UNION ALL
SELECT 'Index', 'IX_Patient_SourceModuleId_LabId',
       CASE WHEN EXISTS (SELECT 1 FROM sys.indexes
                         WHERE name = 'IX_Patient_SourceModuleId_LabId'
                           AND object_id = OBJECT_ID('dbo.Patient'))
            THEN 'present' ELSE 'MISSING' END
UNION ALL
SELECT 'Procedure', p.Name_,
       CASE WHEN OBJECT_ID('[dbo].[' + p.Name_ + ']', 'P') IS NULL THEN 'MISSING' ELSE 'present' END
FROM (VALUES ('LoadModuleIntoLab'), ('GetLabModuleLoads')) AS p(Name_);
GO

/* ===========================================================================
   5. Drift check: does LoadModuleIntoLab copy everything CopyModule copies?
   ---------------------------------------------------------------------------
   The two procedures duplicate the same 20-odd INSERT statements, so a column
   added to one can silently go missing from the other. That is not theoretical:
   the first cut of this script was generated from the CopyModule in Sprint3_02
   rather than the corrected one in Sprint3_06, and quietly dropped
   ModeOfDelivery from every loaded observation.

   For each clinical table, this lists any column CopyModule names that
   LoadModuleIntoLab does not. It must come back empty. Re-run it after touching
   either procedure.

   [[] matches a literal opening bracket; a bare [ starts a wildcard class.
   =========================================================================== */
SELECT  t.name  AS TableName,
        c.name  AS ColumnMissingFromLoadModuleIntoLab
FROM    sys.tables t
JOIN    sys.columns c ON c.object_id = t.object_id
WHERE   t.name IN ('Patient','BradenAssessment','FallRiskAssessments','PatientAdds',
                   'ProgressNotes','FluidBalanceChart','FluidBalanceChartEntry',
                   'FoodIntakeHeader','FoodIntakeItem','IvFluidChart','IvFluidAdministration',
                   'MedicationRegularChart','MedicationRegularAdministration',
                   'MedicationPrnChart','MedicationPrnAdministration',
                   'NeurologicalChart','NeurologicalAdministration',
                   'RiskmanIncident','RiskmanIncidentContributingFactor')
  AND   OBJECT_DEFINITION(OBJECT_ID('dbo.CopyModule'))        LIKE '%[[]' + c.name + ']%'
  AND   OBJECT_DEFINITION(OBJECT_ID('dbo.LoadModuleIntoLab')) NOT LIKE '%[[]' + c.name + ']%'
ORDER BY t.name, c.name;
GO
