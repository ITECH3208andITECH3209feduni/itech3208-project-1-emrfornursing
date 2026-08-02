/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Repair: module-owned rows that were written with a campus LabId

   WHY THIS EXISTS
   ---------------------------------------------------------------------------
   A defect in the sidebar navigation handler restored the campus LabId when a
   supervisor opened a chart screen from inside a module. The patient context
   stayed on the module patient, so charts saved in that state were written with
   LabId = <campus> instead of LabId = 0.

   Those rows are module data sitting inside a campus scope: they appear in that
   campus's queries, which is exactly the isolation the module design exists to
   provide. The navigation defect is fixed; this repairs rows already written.

   SAFE TO RE-RUN. It only touches rows where the patient is module-owned
   (Patient.ModuleId IS NOT NULL) and the row's LabId is not 0. Campus patients
   are never matched, because their ModuleId is NULL.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

DECLARE @Fixed TABLE (TableName SYSNAME, RowsFixed INT);

/* ---- the Patient row itself ------------------------------------------- */
UPDATE p SET p.LabId = 0
FROM [dbo].[Patient] p
WHERE p.ModuleId IS NOT NULL AND ISNULL(p.LabId, 0) <> 0;
INSERT INTO @Fixed VALUES ('Patient', @@ROWCOUNT);

/* ---- every clinical table that carries LabId + PatientId --------------- */
UPDATE t SET t.LabId = 0 FROM [dbo].[BradenAssessment] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('BradenAssessment', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[FallRiskAssessments] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('FallRiskAssessments', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[FluidBalanceChart] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('FluidBalanceChart', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[FoodIntakeHeader] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('FoodIntakeHeader', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[IvFluidChart] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('IvFluidChart', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[IvFluidAdministration] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('IvFluidAdministration', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[MedicationRegularChart] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('MedicationRegularChart', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[MedicationRegularAdministration] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('MedicationRegularAdministration', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[MedicationPrnChart] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('MedicationPrnChart', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[MedicationPrnAdministration] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('MedicationPrnAdministration', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[NeurologicalChart] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('NeurologicalChart', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[NeurologicalAdministration] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('NeurologicalAdministration', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[PatientAdds] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('PatientAdds', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[ProgressNotes] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('ProgressNotes', @@ROWCOUNT);

UPDATE t SET t.LabId = 0 FROM [dbo].[RiskmanIncident] t
  JOIN [dbo].[Patient] p ON p.Id = t.PatientId
  WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0) <> 0;
INSERT INTO @Fixed VALUES ('RiskmanIncident', @@ROWCOUNT);

/* ---- what changed ------------------------------------------------------ */
SELECT '1. Rows repaired' AS Result_, TableName, RowsFixed
FROM @Fixed WHERE RowsFixed > 0
ORDER BY TableName;

IF NOT EXISTS (SELECT 1 FROM @Fixed WHERE RowsFixed > 0)
    SELECT '1. Rows repaired' AS Result_, 'none - nothing needed fixing' AS TableName, 0 AS RowsFixed;

/* ---- verification: this must come back empty --------------------------- */
SELECT '2. Remaining bad rows' AS Result_, x.TableName, x.Id, x.PatientId, x.LabId
FROM (
    SELECT 'FluidBalanceChart' AS TableName, t.Id, t.PatientId, t.LabId FROM [dbo].[FluidBalanceChart] t JOIN [dbo].[Patient] p ON p.Id=t.PatientId WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0)<>0
    UNION ALL SELECT 'PatientAdds', t.Id, t.PatientId, t.LabId FROM [dbo].[PatientAdds] t JOIN [dbo].[Patient] p ON p.Id=t.PatientId WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0)<>0
    UNION ALL SELECT 'ProgressNotes', t.Id, t.PatientId, t.LabId FROM [dbo].[ProgressNotes] t JOIN [dbo].[Patient] p ON p.Id=t.PatientId WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0)<>0
    UNION ALL SELECT 'BradenAssessment', t.Id, t.PatientId, t.LabId FROM [dbo].[BradenAssessment] t JOIN [dbo].[Patient] p ON p.Id=t.PatientId WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0)<>0
    UNION ALL SELECT 'MedicationRegularChart', t.Id, t.PatientId, t.LabId FROM [dbo].[MedicationRegularChart] t JOIN [dbo].[Patient] p ON p.Id=t.PatientId WHERE p.ModuleId IS NOT NULL AND ISNULL(t.LabId,0)<>0
    UNION ALL SELECT 'Patient', p.Id, p.Id, p.LabId FROM [dbo].[Patient] p WHERE p.ModuleId IS NOT NULL AND ISNULL(p.LabId,0)<>0
) x;

/* ---- and confirm no campus patient was touched ------------------------- */
SELECT '3. Campus patients still intact' AS Result_,
       COUNT(*) AS CampusPatientsWithRealLabId
FROM [dbo].[Patient] WHERE ModuleId IS NULL AND ISNULL(LabId,0) <> 0;
GO
