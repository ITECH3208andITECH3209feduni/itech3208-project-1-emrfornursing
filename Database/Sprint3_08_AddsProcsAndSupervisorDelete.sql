/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   ADDS procedure fixes, merged from Kunal's ADDSChart.sql

   RUN AFTER EMRSimulatorFULL-spr3.sql (or against a database already at that
   level). SAFE TO RE-RUN.

   WHAT THIS IS
   ---------------------------------------------------------------------------
   Kunal built the ADDS oxygen changes in parallel with the versions already on
   develop. Most of his script duplicates what is there, but two things in it
   are genuine improvements and one of them fixes a real defect. Only those are
   taken here; the rest of his script is deliberately not applied because it
   would revert the module work.

   1. UpdatePatientAdds ignored eleven of its own parameters
   ---------------------------------------------------------------------------
   The deployed version accepts @RespiratoryRateValue, @OxygenSaturationValue,
   @BloodPressureValue, @BloodPressureDiastolicValue, @HeartRateValue,
   @TemperatureValue, @RespiratoryAlert, @OxygenSaturationAlert,
   @BloodPressureAlert, @HeartRateAlert - and writes none of them.

   So editing an observation would change the readings while leaving every
   derived score and alert at its old value. On an ADDS chart that is a patient
   safety problem in miniature: the recorded observations and the escalation
   score would disagree, and the score is what tells a nurse to call for help.

   It has never fired because no screen edits an observation yet, which is
   exactly why it was worth catching now rather than after one is built.

   2. GetPatientAdds had no ORDER BY
   ---------------------------------------------------------------------------
   Row order was whatever the engine happened to return. Observations are a
   time series and belong in time order. Newest first, matching the progress
   note list.

   NOT TAKEN from his script, and why
   ---------------------------------------------------------------------------
   - His GetPatientAdds lists columns explicitly instead of SELECT *. Ours has
     to stay SELECT * or ModeOfDelivery and anything added later would need the
     list maintained in two places.
   - His InsertPatientAdds and the EnteredDate / EnteredTime NOT NULL changes
     are already in place.
   - His DeletePatientAdds already exists.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

/* ===========================================================================
   1. UpdatePatientAdds - write every parameter it accepts
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

    UPDATE [dbo].[PatientAdds]
    SET
        PatientId                   = @PatientId,
        LabId                       = @LabId,
        RespiratoryRate             = @RespiratoryRate,
        HeartRate                   = @HeartRate,
        Temperature                 = @Temperature,
        Consciousness               = @Consciousness,
        OxygenSaturation            = @OxygenSaturation,
        OxygenFlow                  = @OxygenFlow,
        ModeOfDelivery              = @ModeOfDelivery,
        BloodPressure               = @BloodPressure,
        BloodPressureDiastolic      = @BloodPressureDiastolic,

        /* these eleven were accepted and then discarded */
        RespiratoryRateValue        = @RespiratoryRateValue,
        OxygenSaturationValue       = @OxygenSaturationValue,
        BloodPressureValue          = @BloodPressureValue,
        BloodPressureDiastolicValue = @BloodPressureDiastolicValue,
        HeartRateValue              = @HeartRateValue,
        TemperatureValue            = @TemperatureValue,
        RespiratoryAlert            = @RespiratoryAlert,
        OxygenSaturationAlert       = @OxygenSaturationAlert,
        BloodPressureAlert          = @BloodPressureAlert,
        HeartRateAlert              = @HeartRateAlert,

        ConsciousnessAlert          = @ConsciousnessAlert,
        TotalScore                  = @TotalScore
    WHERE Id = @Id;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No record found with the given Id.', 16, 1);
    END
END
GO

/* ===========================================================================
   2. GetPatientAdds - newest observation first
   ---------------------------------------------------------------------------
   The module predicate from Sprint3_03 is kept. EnteredTime is varchar holding
   HH:mm, which sorts correctly as text for a 24 hour clock, so it needs no
   conversion. Id breaks ties so two observations recorded in the same minute
   keep a stable order.
   =========================================================================== */
IF OBJECT_ID('[dbo].[GetPatientAdds]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetPatientAdds] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetPatientAdds]
    @LabId INT = 0,
    @PatientId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [dbo].[PatientAdds]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
      AND PatientId = @PatientId
    ORDER BY EnteredDate DESC, EnteredTime DESC, Id DESC;
END
GO

/* ===========================================================================
   3. Confirmation
   =========================================================================== */
SELECT 'UpdatePatientAdds writes all value/alert columns' AS Check_,
       CASE WHEN OBJECT_DEFINITION(OBJECT_ID('dbo.UpdatePatientAdds')) LIKE '%RespiratoryRateValue        = @RespiratoryRateValue%'
            THEN 'yes' ELSE 'NO' END AS Status_
UNION ALL
SELECT 'GetPatientAdds orders newest first',
       CASE WHEN OBJECT_DEFINITION(OBJECT_ID('dbo.GetPatientAdds')) LIKE '%ORDER BY EnteredDate DESC%'
            THEN 'yes' ELSE 'NO' END
UNION ALL
SELECT 'GetPatientAdds keeps the module predicate',
       CASE WHEN OBJECT_DEFINITION(OBJECT_ID('dbo.GetPatientAdds')) LIKE '%ISNULL(@LabId, 0) = 0%'
            THEN 'yes' ELSE 'NO' END;
GO

/* ===========================================================================
   4. GetLabs - list the campus labs, for the multi-lab load picker
   ---------------------------------------------------------------------------
   There was no way to list labs at all; only GetLab(@Id). The load picker needs
   the full set so an academic can push a scenario to several campuses at once.

   Filtered on Active because the table holds around thirteen rows, most of them
   test logins from earlier sprints, against the three campuses Naomi describes.
   Which of those are genuine is question 6 in her outstanding list; until she
   answers, Active is the only signal available.

   LabPassword is deliberately not selected.
   =========================================================================== */
IF OBJECT_ID('[dbo].[GetLabs]', 'P') IS NULL
    EXEC('CREATE PROCEDURE [dbo].[GetLabs] AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE [dbo].[GetLabs]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  [Id],
            [LabName],
            ISNULL([Active], 0) AS Active
    FROM    [dbo].[Lab]
    WHERE   (@IncludeInactive = 1 OR ISNULL([Active], 0) = 1)
    ORDER BY [LabName];
END
GO

SELECT 'GetLabs' AS Object_,
       CASE WHEN OBJECT_ID('[dbo].[GetLabs]', 'P') IS NULL THEN 'MISSING' ELSE 'present' END AS Status_;
GO
