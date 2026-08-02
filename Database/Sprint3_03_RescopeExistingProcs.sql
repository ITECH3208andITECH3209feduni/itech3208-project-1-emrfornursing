/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Requirement 1: Global Module Repository & Year-Level Management
   Part 03 of 03 - Re-scope existing procedures so module-owned patients resolve

   Run order : 01_Schema  ->  02_ModuleProcs  ->  03_RescopeExistingProcs
   Idempotent: yes - CREATE-if-missing stub followed by ALTER

   ---------------------------------------------------------------------------
   WHAT THIS DOES
   ---------------------------------------------------------------------------
   Module-owned patients have LabId = NULL, so any predicate of the form
       WHERE LabId = @LabId
   silently returns zero rows for them. This script rewrites that predicate to
       WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
   in the 23 procedures below.

   Callers keep working unchanged: passing a real LabId behaves exactly as
   before. Passing 0 (or NULL) switches the procedure into module mode and
   scopes purely on PatientId, which is safe because every module owns its own
   Patient rows and PatientId is unique across the database.

   Five procedures already used this sentinel (GetPatient, GetIvFluidChart,
   GetNeurologicalChart, GetMedicationPrnChart, GetMedicationRegularChart);
   those occurrences were left alone rather than double-wrapped.

   ---------------------------------------------------------------------------
   DELIBERATELY NOT CHANGED
   ---------------------------------------------------------------------------
   ClearLabData            - its predicate is a bare "WHERE LabId = @LabId"
                             with no PatientId. Making it optional would let a
                             single call wipe every lab. Left strictly scoped.
   ValidateSupervisorLogin - authentication; LabId there is an output
                             assignment, not a filter.
   UpdatePatientAdds       - "SET LabId = @LabId" is a column assignment inside
   UpdateProgressNote        an UPDATE, not a predicate. Rewriting either would
                             have corrupted the statement.
   ============================================================================ */

USE [EmrSimulator];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* ---- ClearPatientData ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[ClearPatientData]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[ClearPatientData] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[ClearPatientData]

	@LabId INT,
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;

	SET NOCOUNT ON;

    DECLARE @DeletedTables TABLE (
		TableName NVARCHAR(100), 
		RowsDeleted INT
		);

    -- Delete from IvFluidAdministration and track rows affected
    DECLARE @RowsDeleted INT;

    DELETE FROM [dbo].[FallRiskAssessments]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Fall Risk Assessments', @RowsDeleted);

    DELETE FROM [dbo].[BradenAssessment]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Braden Assessment', @RowsDeleted);

    DELETE FROM [dbo].[NeurologicalAdministration]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Neurological Administration', @RowsDeleted);

    DELETE FROM [dbo].[FoodIntakeHeader]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Food Intake', @RowsDeleted);

    DELETE FROM [dbo].[IvFluidAdministration]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Iv Fluid', @RowsDeleted);

    -- Delete from MedicationPrnAdministration and track rows affected
    DELETE FROM [dbo].[MedicationPrnAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student PRN Medication', @RowsDeleted);

    -- Delete from MedicationRegularAdministration and track rows affected
    DELETE FROM [dbo].[MedicationRegularAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Regular Medication', @RowsDeleted);

    -- Delete from PatientAdds and track rows affected
    DELETE FROM [dbo].[PatientAdds]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Patient Adds', @RowsDeleted);

	-- Delete from Patient Progress Notes and track rows affected
    DELETE FROM [dbo].[ProgressNotes]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId
	AND NotesFrom = 'student'
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Progress Notes', @RowsDeleted);

	UPDATE Patient SET Alert = 0 WHERE Id = @PatientId

    -- Return the list of deleted tables and number of rows deleted
    SELECT * FROM @DeletedTables;
END
GO

/* ---- ClearPatientDataSelective ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[ClearPatientDataSelective]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[ClearPatientDataSelective] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[ClearPatientDataSelective]

    @LabId          INT,
    @PatientId      INT,
    @FallRisk       BIT = 0,
    @Braden         BIT = 0,
    @Neuro          BIT = 0,
    @FoodIntake     BIT = 0,
    @IvFluid        BIT = 0,
    @Prn            BIT = 0,
    @Regular        BIT = 0,
    @PatientAdds    BIT = 0,
    @ProgressNotes  BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DeletedTables TABLE (TableName NVARCHAR(100), RowsDeleted INT);
    DECLARE @RowsDeleted INT;

    IF @FallRisk = 1
    BEGIN
        DELETE FROM [dbo].[FallRiskAssessments] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Fall Risk Assessments', @RowsDeleted);
    END

    IF @Braden = 1
    BEGIN
        DELETE FROM [dbo].[BradenAssessment] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Braden Assessment', @RowsDeleted);
    END

    IF @Neuro = 1
    BEGIN
        DELETE FROM [dbo].[NeurologicalAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Neurological Administration', @RowsDeleted);
    END

    IF @FoodIntake = 1
    BEGIN
        DELETE FROM [dbo].[FoodIntakeHeader] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Food Intake', @RowsDeleted);
    END

    IF @IvFluid = 1
    BEGIN
        DELETE FROM [dbo].[IvFluidAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Iv Fluid', @RowsDeleted);
    END

    IF @Prn = 1
    BEGIN
        DELETE FROM [dbo].[MedicationPrnAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student PRN Medication', @RowsDeleted);
    END

    IF @Regular = 1
    BEGIN
        DELETE FROM [dbo].[MedicationRegularAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Regular Medication', @RowsDeleted);
    END

    IF @PatientAdds = 1
    BEGIN
        DELETE FROM [dbo].[PatientAdds] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Patient Adds', @RowsDeleted);
    END

    IF @ProgressNotes = 1
    BEGIN
        DELETE FROM [dbo].[ProgressNotes] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId AND NotesFrom = 'student';
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Progress Notes', @RowsDeleted);
    END

    -- Only reset the alert flag on a complete clear (all 9 selected)
    IF (@FallRisk = 1 AND @Braden = 1 AND @Neuro = 1 AND @FoodIntake = 1 AND @IvFluid = 1
        AND @Prn = 1 AND @Regular = 1 AND @PatientAdds = 1 AND @ProgressNotes = 1)
    BEGIN
        UPDATE Patient SET Alert = 0 WHERE Id = @PatientId;
    END

    SELECT * FROM @DeletedTables;
END
GO

/* ---- DeletePatient ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[DeletePatient]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[DeletePatient] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[DeletePatient]

    @Id INT,
	@LabId INT
AS
BEGIN

-- Delete from IvFluidAdministration and track rows affected
	DELETE FROM [dbo].[IvFluidChart]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @Id;

    DELETE FROM [dbo].[IvFluidAdministration]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

	DELETE FROM [dbo].[MedicationPrnChart]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @Id;

    DELETE FROM [dbo].[MedicationPrnAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

	DELETE FROM [dbo].[MedicationRegularChart]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @Id;

    -- Delete from MedicationRegularAdministration and track rows affected
    DELETE FROM [dbo].[MedicationRegularAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

    -- Delete from PatientAdds and track rows affected
    DELETE FROM [dbo].[PatientAdds]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

	-- Delete from Patient Progress Notes and track rows affected
    DELETE FROM [dbo].[ProgressNotes]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id
	AND NotesFrom = 'student'

    DELETE FROM Patient
    WHERE [Id] = @Id
	AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId);

	-- Optionally, return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

/* ---- GetBradenAssessmentById ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetBradenAssessmentById]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetBradenAssessmentById] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetBradenAssessmentById]

  @LabId INT,
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      Id, LabId, PatientId, DateOfAssessment, NurseInitials,
      Sensory, Moisture, Activity, Mobility, Nutrition, Friction,
      TotalScore, RiskKey, Shift
  FROM dbo.BradenAssessment
  WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND Id    = @Id;
END
GO

/* ---- GetBradenAssessments ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetBradenAssessments]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetBradenAssessments] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetBradenAssessments]

  @LabId INT,
  @PatientId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      Id,
      LabId,
      PatientId,
      DateOfAssessment,
      Shift,
      NurseInitials,
      TotalScore,
      RiskKey
  FROM dbo.BradenAssessment
  WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND (@PatientId IS NULL OR PatientId = @PatientId)
  ORDER BY DateOfAssessment DESC, Id DESC;
END
GO

/* ---- GetFluidBalanceChartById ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetFluidBalanceChartById]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetFluidBalanceChartById] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetFluidBalanceChartById]

    @Id    INT,
    @LabId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, LabId, PatientId, ChartDate, ChartTime,
           PreviousDayBalance, TotalIntake, TotalOutput,
           Balance, TotalBalance, ClinicalNotes,
           SignatureData, CreatedDateTime, UpdatedDateTime
    FROM [dbo].[FluidBalanceChart]
    WHERE Id = @Id AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId);
    SELECT e.Id, e.FluidBalanceChartId, e.EntryDate, e.EntryTime,
           e.EntryType, e.Category, e.AmountMl, e.Initials, e.CreatedDateTime
    FROM [dbo].[FluidBalanceChartEntry] e
    WHERE e.FluidBalanceChartId = @Id
    ORDER BY e.EntryDate, e.EntryTime;
END
GO

/* ---- GetFluidBalanceCharts ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetFluidBalanceCharts]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetFluidBalanceCharts] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetFluidBalanceCharts]

    @LabId     INT,
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.Id, c.LabId, c.PatientId, c.ChartDate, c.ChartTime,
        c.PreviousDayBalance, c.TotalIntake, c.TotalOutput,
        c.Balance, c.TotalBalance, c.ClinicalNotes,
        c.SignatureData, c.CreatedDateTime, c.UpdatedDateTime,
        ISNULL(
            (SELECT MIN(e.EntryDate) FROM [dbo].[FluidBalanceChartEntry] e
             WHERE e.FluidBalanceChartId = c.Id),
            c.ChartDate
        ) AS EarliestEntryDate,
        ISNULL(
            (SELECT MAX(e.EntryDate) FROM [dbo].[FluidBalanceChartEntry] e
             WHERE e.FluidBalanceChartId = c.Id),
            c.ChartDate
        ) AS LatestEntryDate,
        ISNULL(
            STUFF((
                SELECT DISTINCT ', ' + e.Initials
                FROM [dbo].[FluidBalanceChartEntry] e
                WHERE e.FluidBalanceChartId = c.Id
                  AND e.Initials IS NOT NULL
                  AND LTRIM(RTRIM(e.Initials)) <> ''
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''),
            ''
        ) AS CompletedBy
    FROM [dbo].[FluidBalanceChart] c
    WHERE (ISNULL(@LabId, 0) = 0 OR c.LabId = @LabId) AND c.PatientId = @PatientId
    ORDER BY EarliestEntryDate DESC, c.CreatedDateTime DESC;
END
GO

/* ---- GetFoodIntakeById ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetFoodIntakeById]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetFoodIntakeById] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetFoodIntakeById]

  @LabId INT,
  @Id    INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT TOP (1)
    h.Id, h.LabId, h.PatientId, h.DayText, h.IntakeDate,
    h.Shift1Signature, h.Shift1Designation,
    h.Shift2Signature, h.Shift2Designation,
	h.Shift3Signature, h.Shift3Designation,
    h.BreakfastComment, h.MorningTeaComment,
    h.LunchComment, h.AfternoonTeaComment, h.DinnerComment, h.SupperComment
  FROM dbo.FoodIntakeHeader h
  WHERE (ISNULL(@LabId, 0) = 0 OR h.LabId = @LabId) AND h.Id = @Id;

  SELECT
    i.Id, i.Meal, i.Label, i.Notes, i.Amount
  FROM dbo.FoodIntakeItem i
  WHERE i.HeaderId = @Id
  ORDER BY CASE i.Meal
             WHEN 'Breakfast'     THEN 1
             WHEN 'Morning tea'   THEN 2
             WHEN 'Lunch'         THEN 3
             WHEN 'Afternoon tea' THEN 4
             WHEN 'Dinner'        THEN 5
             WHEN 'Supper'        THEN 6
             ELSE 99
           END,
           i.Id;
END
GO

/* ---- GetIvFluidAdministration ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetIvFluidAdministration]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetIvFluidAdministration] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetIvFluidAdministration]

    @LabId INT,
    @PatientId INT,
    @IvFluidChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LabId,
        PatientId,
        IvFluidChartId,
        StartDate,
        StartTime,
        EndDate,
        EndTime,
        VolGiven,
        PharmacistReview,
        NurseSign,
		CoSign
    FROM [dbo].[IvFluidAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND IvFluidChartId = @IvFluidChartId;
END
GO

/* ---- GetMedication ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetMedication]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetMedication] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetMedication]
 
	-- Add the parameters for the stored procedure here
	@LabId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM Medication
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
END
GO

/* ---- GetMedicationPrnAdministration ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetMedicationPrnAdministration]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetMedicationPrnAdministration] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetMedicationPrnAdministration]

    @LabId INT,
    @PatientId INT,
    @PatientMedicationChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        *
    FROM [dbo].[MedicationPrnAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND PatientMedicationChartId = @PatientMedicationChartId;
END
GO

/* ---- GetMedicationPrnChart ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetMedicationPrnChart]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetMedicationPrnChart] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetMedicationPrnChart]
 
	-- Add the parameters for the stored procedure here
	@Id INT = 0,
	@LabId INT = 0,
	@PatientId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Id, 
		(SELECT Name FROM Medication M WHERE M.Id = C.MedicationId AND (ISNULL(@LabId, 0) = 0 OR M.LabId = @LabId)) AS MedicationName, *
		
	FROM MedicationPrnChart C 
	WHERE (@LabId = 0 OR LabId = @LabId) 
      AND (@PatientId = 0 OR PatientId = @PatientId)
      AND (@Id = 0 OR Id = @Id);
END
GO

/* ---- GetMedicationRegularAdministration ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetMedicationRegularAdministration]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetMedicationRegularAdministration] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetMedicationRegularAdministration]

    @LabId INT,
    @PatientId INT,
    @PatientMedicationChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        *
    FROM [dbo].[MedicationRegularAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND PatientMedicationChartId = @PatientMedicationChartId;
END
GO

/* ---- GetMedicationRegularChart ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetMedicationRegularChart]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetMedicationRegularChart] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetMedicationRegularChart]
 
	-- Add the parameters for the stored procedure here
	@Id INT = 0,
	@LabId INT = 0,
	@PatientId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Id, 
		(SELECT Name FROM Medication M WHERE M.Id = C.MedicationId AND (ISNULL(@LabId, 0) = 0 OR M.LabId = @LabId)) AS MedicationName, *
		
	FROM MedicationRegularChart C 
	WHERE (@LabId = 0 OR LabId = @LabId) 
      AND (@PatientId = 0 OR PatientId = @PatientId)
      AND (@Id = 0 OR Id = @Id);
END
GO

/* ---- GetNeurologicalAdministration ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetNeurologicalAdministration]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetNeurologicalAdministration] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetNeurologicalAdministration]

    @LabId INT,
    @PatientId INT,
    @NeurologicalChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LabId,
        PatientId,
        NeurologicalChartId,
        StartDate,
        StartTime,
        EndDate,
        EndTime,
        PharmacistReview,
        NurseSign,
		CoSign
    FROM [dbo].[NeurologicalAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND NeurologicalChartId = @NeurologicalChartId;
END
GO

/* ---- GetPatientAdds ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetPatientAdds]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetPatientAdds] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetPatientAdds]
 
	-- Add the parameters for the stored procedure here
	@LabId INT = 0,
	@PatientId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM PatientAdds
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
	AND PatientId = @PatientId
END
GO

/* ---- GetProgressNotes ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetProgressNotes]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetProgressNotes] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetProgressNotes]

    @LabId INT = NULL, -- Optional parameter to filter by Id
	@PatientId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

	SELECT Id, LabId, Notes, Sign, NotesDate, PatientId, NotesFrom
		FROM ProgressNotes
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @PatientId
	ORDER BY NotesFrom DESC
    
END
GO

/* ---- GetRiskmanIncident ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetRiskmanIncident]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetRiskmanIncident] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetRiskmanIncident]

  @LabId INT,
  @PatientId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      Id, LabId, PatientId, IncidentDate, IncidentTime, URINumber,
      Campus, WardLocationType, PersonName,
      DateOfBirth, Sex, IndigenousStatus, BriefSummary, Details, EventType, EventSubType
  FROM dbo.RiskmanIncident
  WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND (@PatientId IS NULL OR PatientId = @PatientId)
  ORDER BY IncidentDate DESC, Id DESC;
END
GO

/* ---- GetRiskmanIncidentById ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[GetRiskmanIncidentById]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetRiskmanIncidentById] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetRiskmanIncidentById]

    @LabId INT,
    @Id    INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.Id, i.LabId, i.PatientId, i.IncidentDate, i.IncidentTime, i.URINumber,
        i.Campus, i.WardLocationType, i.PersonName, i.DateOfBirth, i.Sex, i.IndigenousStatus,
        i.BriefSummary, i.Details, i.EventType, i.EventSubType,
        i.IsClinicalIncident, i.Apse, i.ClinicalHarmLevel, i.HarmDuration, i.RequiredCareLevelClinical,
        i.EmergencyResponseType, i.EmergencyResponseOutcome,
        i.ContributingAdditionalDetail,
        i.ReporterIsAffectedStaff, i.OhsTypeOfInjury, i.OhsTypeOfInjuryOther, i.OhsBodyPartAffected, i.OhsBodyPartOther,
        i.OhsLevelOfHarmSustained, i.OhsRequiredLevelOfCare, i.OhsActionsRequired,
		i.NextOfKinNotifiedDate, i.NextOfKinNotifiedTime, 
        i.SignedBy, i.SignedDate,
        -- aggregated factors for the repo to split into List<string>
        (SELECT STRING_AGG(LTRIM(RTRIM(cf.FactorCode)), ',')
           FROM dbo.RiskmanIncidentContributingFactor cf
          WHERE cf.IncidentId = i.Id) AS FactorsCsv
    FROM dbo.RiskmanIncident i
    WHERE (ISNULL(@LabId, 0) = 0 OR i.LabId = @LabId)
      AND i.Id    = @Id;
END
GO

/* ---- InsertBradenAssessment ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[InsertBradenAssessment]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[InsertBradenAssessment] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[InsertBradenAssessment]

  @LabId INT,
  @PatientId INT,
  @DateOfAssessment DATE,
  @NurseInitials NVARCHAR(10),
  @Sensory INT,
  @Moisture INT,
  @Activity INT,
  @Mobility INT,
  @Nutrition INT,
  @Friction INT,
  @TotalScore INT,
  @RiskKey NVARCHAR(50),
  @Shift NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- ✅ Guard: block any second “initial” row for this LabId+PatientId
  -- UPDLOCK+HOLDLOCK prevents race conditions under concurrency
  IF EXISTS (
      SELECT 1
      FROM dbo.BradenAssessment WITH (UPDLOCK, HOLDLOCK)
      WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId
  )
  BEGIN
    SELECT CAST(-1 AS INT);
    RETURN;
  END

  INSERT INTO dbo.BradenAssessment
  (
    LabId, PatientId, DateOfAssessment, NurseInitials,
    Sensory, Moisture, Activity, Mobility, Nutrition, Friction,
    TotalScore, RiskKey, Shift
  )
  VALUES
  (
    @LabId, @PatientId, @DateOfAssessment, @NurseInitials,
    @Sensory, @Moisture, @Activity, @Mobility, @Nutrition, @Friction,
    @TotalScore, @RiskKey, @Shift
  );

  SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

/* ---- InsertBradenAssessmentFollowUp ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[InsertBradenAssessmentFollowUp]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[InsertBradenAssessmentFollowUp] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[InsertBradenAssessmentFollowUp]

  @LabId INT,
  @PatientId INT,
  @DateOfAssessment DATE,
  @NurseInitials NVARCHAR(10),
  @Sensory INT,
  @Moisture INT,
  @Activity INT,
  @Mobility INT,
  @Nutrition INT,
  @Friction INT,
  @TotalScore INT,
  @RiskKey NVARCHAR(50),
  @Shift NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- ✅ Guard: must already have an initial assessment
  IF NOT EXISTS (
      SELECT 1
      FROM dbo.BradenAssessment
      WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId
  )
  BEGIN
    SELECT CAST(-1 AS INT);  -- signal: no initial exists
    RETURN;
  END

  INSERT INTO dbo.BradenAssessment
  (
    LabId, PatientId, DateOfAssessment, NurseInitials,
    Sensory, Moisture, Activity, Mobility, Nutrition, Friction,
    TotalScore, RiskKey, Shift
  )
  VALUES
  (
    @LabId, @PatientId, @DateOfAssessment, @NurseInitials,
    @Sensory, @Moisture, @Activity, @Mobility, @Nutrition, @Friction,
    @TotalScore, @RiskKey, @Shift
  );

  SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

/* ---- InsertPatientAdds ---------------------------------------------------- */
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
    @BloodPressure VARCHAR(20) = NULL,
	@BloodPressureDiastolic VARCHAR(20) = NULL,

	@RespiratoryRateValue INT = NULL,
	@OxygenSaturationValue INT = NULL,
	@BloodPressureValue	INT = NULL,
	@BloodPressureDiastolicValue	INT = NULL,
	@HeartRateValue	INT = NULL,
	@TemperatureValue INT = NULL,


	@RespiratoryAlert INT = NULL,
	@OxygenSaturationAlert INT	= NULL,
	@BloodPressureAlert	INT	= NULL,
	@HeartRateAlert	INT	= NULL,
	@ConsciousnessAlert INT = NULL,
	@TotalScore INT = NULL

AS
BEGIN
    -- Set NOCOUNT ON to avoid extra result sets being returned.
    SET NOCOUNT ON;

	IF (@RespiratoryAlert = 1 OR @OxygenSaturationAlert = 1 OR @BloodPressureAlert = 1 OR @HeartRateAlert = 1 OR @ConsciousnessAlert = 1)
	BEGIN
		UPDATE Patient SET Alert = 1 WHERE Id = @PatientId AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	END

    INSERT INTO PatientAdds (PatientId, LabId, EnteredDate, EnteredTime, RespiratoryRate, HeartRate, Temperature, Consciousness, OxygenSaturation, OxygenFlow, BloodPressure, 
	BloodPressureDiastolic, RespiratoryRateValue, OxygenSaturationValue, BloodPressureValue, BloodPressureDiastolicValue, HeartRateValue, TemperatureValue,
	RespiratoryAlert, OxygenSaturationAlert, BloodPressureAlert, HeartRateAlert, ConsciousnessAlert, TotalScore)
    VALUES (@PatientId, @LabId, @EnteredDate, @EnteredTime, @RespiratoryRate, @HeartRate, @Temperature, @Consciousness, @OxygenSaturation, @OxygenFlow, @BloodPressure, 
	@BloodPressureDiastolic, @RespiratoryRateValue, @OxygenSaturationValue, @BloodPressureValue, @BloodPressureDiastolicValue, @HeartRateValue, @TemperatureValue,
	@RespiratoryAlert, @OxygenSaturationAlert, @BloodPressureAlert, @HeartRateAlert, @ConsciousnessAlert, @TotalScore);

    -- Return the identity of the new record
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

/* ---- UpdateFoodIntake ---------------------------------------------------- */
IF OBJECT_ID('[dbo].[UpdateFoodIntake]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[UpdateFoodIntake] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[UpdateFoodIntake]

  @Id                 INT,
  @LabId              INT,
  @PatientId          INT,
  @DayText            NVARCHAR(10) = NULL,
  @IntakeDate         DATE,
  @Shift1Signature    NVARCHAR(40) = NULL,
  @Shift1Designation  NVARCHAR(40) = NULL,
  @Shift2Signature    NVARCHAR(40) = NULL,
  @Shift2Designation  NVARCHAR(40) = NULL,
  @Shift3Signature    NVARCHAR(40) = NULL,
  @Shift3Designation  NVARCHAR(40) = NULL,
  @BreakfastComment    NVARCHAR(200) = NULL,
  @MorningTeaComment   NVARCHAR(200) = NULL,
  @LunchComment        NVARCHAR(200) = NULL,
  @AfternoonTeaComment NVARCHAR(200) = NULL,
  @DinnerComment       NVARCHAR(200) = NULL,
  @SupperComment       NVARCHAR(200) = NULL,
  @ItemsJson          NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM dbo.FoodIntakeHeader
    WHERE Id=@Id AND (ISNULL(@LabId, 0) = 0 OR LabId=@LabId) AND PatientId=@PatientId
  )
  BEGIN
    SELECT CAST(0 AS INT); RETURN;
  END

  UPDATE dbo.FoodIntakeHeader
  SET DayText            = @DayText,
      IntakeDate         = @IntakeDate,
      Shift1Signature    = @Shift1Signature,
      Shift1Designation  = @Shift1Designation,
      Shift2Signature    = @Shift2Signature,
      Shift2Designation  = @Shift2Designation,
      Shift3Signature    = @Shift3Signature,
      Shift3Designation  = @Shift3Designation,
      BreakfastComment    = @BreakfastComment,
      MorningTeaComment   = @MorningTeaComment,
      LunchComment        = @LunchComment,
      AfternoonTeaComment = @AfternoonTeaComment,
      DinnerComment       = @DinnerComment,
      SupperComment       = @SupperComment
  WHERE Id=@Id;

  DELETE FROM dbo.FoodIntakeItem WHERE HeaderId=@Id;

  INSERT INTO dbo.FoodIntakeItem (HeaderId, Meal, Label, Notes, Amount)
  SELECT
    @Id, j.Meal, j.Label, j.Notes, j.Amount
  FROM OPENJSON(@ItemsJson)
  WITH (
    Meal   NVARCHAR(30)  '$.Meal',
    Label  NVARCHAR(50)  '$.Label',
    Notes  NVARCHAR(200) '$.Notes',
    Amount NVARCHAR(10)  '$.Amount'
  ) AS j;

  SELECT CAST(1 AS INT);
END
GO

PRINT '=== Sprint3 Part 03 (Re-scope) complete ===';
GO
