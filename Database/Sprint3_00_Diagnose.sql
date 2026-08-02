/* ============================================================================
   Sprint 3 - Diagnostic. READ ONLY: creates, alters and deletes nothing.
   Run against EmrSimulator in SSMS and paste all four result sets back.
   ============================================================================ */
USE [EmrSimulator];
GO

/* ---- 1. Did the new tables and column get created? ---- */
SELECT '1. Schema objects' AS Check_,
       obj                 AS Object_,
       CASE WHEN present = 1 THEN 'PRESENT' ELSE '** MISSING **' END AS Status
FROM (
    SELECT 'Table: YearLevel' AS obj,
           CASE WHEN OBJECT_ID('dbo.YearLevel') IS NULL THEN 0 ELSE 1 END AS present
    UNION ALL SELECT 'Table: Unit',
           CASE WHEN OBJECT_ID('dbo.Unit') IS NULL THEN 0 ELSE 1 END
    UNION ALL SELECT 'Table: Module',
           CASE WHEN OBJECT_ID('dbo.Module') IS NULL THEN 0 ELSE 1 END
    UNION ALL SELECT 'Column: Patient.ModuleId',
           CASE WHEN COL_LENGTH('dbo.Patient','ModuleId') IS NULL THEN 0 ELSE 1 END
    UNION ALL SELECT 'FK: FK_Patient_Module',
           CASE WHEN EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Patient_Module') THEN 1 ELSE 0 END
    UNION ALL SELECT 'Index: IX_Patient_ModuleId',
           CASE WHEN EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Patient_ModuleId') THEN 1 ELSE 0 END
) x
ORDER BY obj;

/* ---- 2. Which Sprint 3 procedures exist? ---- */
SELECT '2. New procs' AS Check_, name AS Object_,
       CASE WHEN OBJECT_ID('dbo.'+name,'P') IS NULL THEN '** MISSING **' ELSE 'PRESENT' END AS Status
FROM (VALUES ('GetYearLevels'),('InsertYearLevel'),('UpdateYearLevel'),
             ('GetUnits'),('InsertUnit'),('UpdateUnit'),
             ('GetModules'),('GetModuleById'),('GetPatientsByModule'),
             ('InsertModule'),('UpdateModule'),('DeleteModule'),('CopyModule')) v(name)
ORDER BY name;

/* ---- 3. Did the re-scope actually apply to the 23 existing procs? ----
   Looks for the new sentinel text inside each procedure definition.        */
SELECT '3. Re-scoped procs' AS Check_,
       v.name AS Object_,
       CASE
         WHEN OBJECT_ID('dbo.'+v.name,'P') IS NULL THEN '** PROC MISSING **'
         WHEN OBJECT_DEFINITION(OBJECT_ID('dbo.'+v.name,'P')) LIKE '%ISNULL(@LabId, 0) = 0%'
              THEN 'RE-SCOPED'
         ELSE '** STILL ORIGINAL **'
       END AS Status
FROM (VALUES ('ClearPatientData'),('ClearPatientDataSelective'),('DeletePatient'),
             ('GetBradenAssessmentById'),('GetBradenAssessments'),
             ('GetFluidBalanceChartById'),('GetFluidBalanceCharts'),
             ('GetFoodIntakeById'),('GetIvFluidAdministration'),('GetMedication'),
             ('GetMedicationPrnAdministration'),('GetMedicationPrnChart'),
             ('GetMedicationRegularAdministration'),('GetMedicationRegularChart'),
             ('GetNeurologicalAdministration'),('GetPatientAdds'),('GetProgressNotes'),
             ('GetRiskmanIncident'),('GetRiskmanIncidentById'),
             ('InsertBradenAssessment'),('InsertBradenAssessmentFollowUp'),
             ('InsertPatientAdds'),('UpdateFoodIntake')) v(name)
ORDER BY Status DESC, v.name;

/* ---- 4. Data still intact? (confirms nothing was lost) ---- */
SELECT '4. Row counts' AS Check_, 'Lab' AS Table_, COUNT(*) AS Rows_ FROM dbo.Lab
UNION ALL SELECT '4. Row counts','Supervisor', COUNT(*) FROM dbo.Supervisor
UNION ALL SELECT '4. Row counts','Patient',    COUNT(*) FROM dbo.Patient
UNION ALL SELECT '4. Row counts','Medication', COUNT(*) FROM dbo.Medication
UNION ALL SELECT '4. Row counts','FluidBalanceChart', COUNT(*) FROM dbo.FluidBalanceChart
UNION ALL SELECT '4. Row counts','ProgressNotes',     COUNT(*) FROM dbo.ProgressNotes;
GO
