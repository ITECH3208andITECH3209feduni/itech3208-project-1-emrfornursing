/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Functional smoke test for the module repository.

   SAFE: the whole test runs inside a transaction that is ALWAYS rolled back.
   Nothing is left behind and your existing 52 patients cannot be touched -
   every row it creates belongs to a throwaway module.

   What it proves:
     - InsertModule creates a module and its blank patient
     - CopyModule deep-copies patient + all charts, remapping parent/child keys
     - child rows follow their new parents (the part most likely to be wrong)
     - copied patients are module-owned (LabId 0) and carry the new ModuleId
     - the four NOT NULL LabId tables accept module-owned rows
     - DeleteModule cascades cleanly

   Run in SSMS against EmrSimulator and paste back the result sets.
   ============================================================================ */

USE [EmrSimulator];
GO
SET NOCOUNT ON;
GO

BEGIN TRANSACTION SmokeTest;

BEGIN TRY

    DECLARE @UnitId  INT, @SrcModId INT, @CopyModId INT,
            @SrcPat  INT, @CopyPat  INT, @FbcId INT, @RegChartId INT;
    DECLARE @ids TABLE (Id INT);

    /* ---- 0. a unit to hang the test module off ------------------------- */
    SELECT TOP 1 @UnitId = [Id] FROM [dbo].[Unit] ORDER BY [Id];
    IF @UnitId IS NULL
    BEGIN
        RAISERROR('No rows in dbo.Unit - run Sprint3_01 seed section first.', 16, 1);
        RETURN;
    END

    /* ---- 1. create the source module ----------------------------------- */
    INSERT INTO @ids
    EXEC [dbo].[InsertModule]
         @UnitId = @UnitId,
         @ModuleName = '__SMOKETEST_SOURCE__',
         @Description = N'temporary - rolled back';
    SELECT @SrcModId = Id FROM @ids;
    DELETE FROM @ids;

    SELECT @SrcPat = [Id] FROM [dbo].[Patient] WHERE [ModuleId] = @SrcModId;

    /* ---- 2. populate it with representative clinical data --------------- */
    UPDATE [dbo].[Patient]
       SET [FirstName]='Smoke', [LastName]='Test', [UriNumber]='URI-SMOKE'
     WHERE [Id] = @SrcPat;

    INSERT INTO [dbo].[ProgressNotes] ([LabId],[Notes],[Sign],[NotesDate],[PatientId],[NotesFrom])
    VALUES (0, 'smoke note 1', 'ST', GETDATE(), @SrcPat, 'super'),
           (0, 'smoke note 2', 'ST', GETDATE(), @SrcPat, 'super');

    INSERT INTO [dbo].[PatientAdds] ([PatientId],[EnteredDate],[EnteredTime],[LabId],[RespiratoryRate],[HeartRate])
    VALUES (@SrcPat, CAST(GETDATE() AS DATE), '08:00', 0, '18', '82');

    /* BradenAssessment declares Sensory/Moisture/Activity/Mobility/Nutrition/
       Friction/RiskKey NOT NULL, so all seven must be supplied here. CopyModule
       is unaffected - it carries every column across from the source row. */
    INSERT INTO [dbo].[BradenAssessment]
        ([LabId],[PatientId],[DateOfAssessment],[NurseInitials],
         [Sensory],[Moisture],[Activity],[Mobility],[Nutrition],[Friction],
         [TotalScore],[RiskKey],[Shift])
    VALUES (0, @SrcPat, GETDATE(), 'ST',
            3, 3, 3, 3, 3, 3,
            18, 'Mild', 'AM');

    /* parent + children: fluid balance */
    INSERT INTO [dbo].[FluidBalanceChart]
        ([LabId],[PatientId],[ChartDate],[ChartTime],[PreviousDayBalance],
         [TotalIntake],[TotalOutput],[Balance],[TotalBalance],[CreatedDateTime])
    VALUES (0, @SrcPat, GETDATE(), '08:00', 500, 1000, 400, 600, 1100, GETDATE());
    SET @FbcId = CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO [dbo].[FluidBalanceChartEntry]
        ([FluidBalanceChartId],[EntryTime],[EntryType],[Category],[AmountMl],[CreatedDateTime],[EntryDate],[Initials])
    /* EntryTime is varchar(4): the UI writes HHMM ('0800'), not '08:00'. */
    VALUES (@FbcId,'0800','Intake','Oral', 600,GETDATE(),GETDATE(),'ST'),
           (@FbcId,'1200','Intake','IV',   400,GETDATE(),GETDATE(),'ST'),
           (@FbcId,'1400','Output','Urine',400,GETDATE(),GETDATE(),'ST');

    /* parent + children: regular medication */
    INSERT INTO [dbo].[MedicationRegularChart]
        ([LabId],[PatientId],[MedicationId],[Dose],[DoseFrequency],[DoseDate],[DoseTime],[Indication],[Route])
    VALUES (0, @SrcPat, (SELECT TOP 1 [Id] FROM [dbo].[Medication] ORDER BY [Id]),
            '5mg','BD',GETDATE(),'08:00','smoke test','PO');
    SET @RegChartId = CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO [dbo].[MedicationRegularAdministration]
        ([LabId],[PatientId],[PatientMedicationChartId],[DoseDate],[DoseTime],[Route],[StudentSign],[Dose])
    VALUES (0,@SrcPat,@RegChartId,GETDATE(),'08:00','PO','ST','5mg'),
           (0,@SrcPat,@RegChartId,GETDATE(),'20:00','PO','ST','5mg');

    /* ---- 3. THE TEST: copy the module ----------------------------------- */
    INSERT INTO @ids
    EXEC [dbo].[CopyModule]
         @SourceModuleId = @SrcModId,
         @NewModuleName  = '__SMOKETEST_COPY__';
    SELECT @CopyModId = Id FROM @ids;
    DELETE FROM @ids;

    SELECT @CopyPat = [Id] FROM [dbo].[Patient] WHERE [ModuleId] = @CopyModId;

    /* ---- 4. compare source vs copy, table by table ---------------------- */
    SELECT 'A. Row counts' AS Test_, t.Table_, t.Src, t.Cpy,
           CASE WHEN t.Src = t.Cpy AND t.Src > 0 THEN 'PASS' ELSE '** FAIL **' END AS Result
    FROM (
        SELECT 'Patient' AS Table_,
               (SELECT COUNT(*) FROM [dbo].[Patient] WHERE [ModuleId]=@SrcModId) AS Src,
               (SELECT COUNT(*) FROM [dbo].[Patient] WHERE [ModuleId]=@CopyModId) AS Cpy
        UNION ALL SELECT 'ProgressNotes',
               (SELECT COUNT(*) FROM [dbo].[ProgressNotes] WHERE [PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[ProgressNotes] WHERE [PatientId]=@CopyPat)
        UNION ALL SELECT 'PatientAdds',
               (SELECT COUNT(*) FROM [dbo].[PatientAdds] WHERE [PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[PatientAdds] WHERE [PatientId]=@CopyPat)
        UNION ALL SELECT 'BradenAssessment',
               (SELECT COUNT(*) FROM [dbo].[BradenAssessment] WHERE [PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[BradenAssessment] WHERE [PatientId]=@CopyPat)
        UNION ALL SELECT 'FluidBalanceChart',
               (SELECT COUNT(*) FROM [dbo].[FluidBalanceChart] WHERE [PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[FluidBalanceChart] WHERE [PatientId]=@CopyPat)
        UNION ALL SELECT 'FluidBalanceChartEntry (child)',
               (SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] e
                  JOIN [dbo].[FluidBalanceChart] c ON c.[Id]=e.[FluidBalanceChartId] WHERE c.[PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] e
                  JOIN [dbo].[FluidBalanceChart] c ON c.[Id]=e.[FluidBalanceChartId] WHERE c.[PatientId]=@CopyPat)
        UNION ALL SELECT 'MedicationRegularChart',
               (SELECT COUNT(*) FROM [dbo].[MedicationRegularChart] WHERE [PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[MedicationRegularChart] WHERE [PatientId]=@CopyPat)
        UNION ALL SELECT 'MedicationRegularAdmin (child)',
               (SELECT COUNT(*) FROM [dbo].[MedicationRegularAdministration] WHERE [PatientId]=@SrcPat),
               (SELECT COUNT(*) FROM [dbo].[MedicationRegularAdministration] WHERE [PatientId]=@CopyPat)
    ) t;

    /* ---- 5. the critical check: do children point at the NEW parents? --- */
    SELECT 'B. Key remapping' AS Test_, Check_, Detail_, Result
    FROM (
        SELECT 'FBC entries reference copied chart' AS Check_,
               CAST((SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] e
                     JOIN [dbo].[FluidBalanceChart] c ON c.[Id]=e.[FluidBalanceChartId]
                     WHERE c.[PatientId]=@CopyPat AND c.[Id] <> @FbcId) AS VARCHAR(20)) + ' of 3' AS Detail_,
               CASE WHEN (SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] e
                          JOIN [dbo].[FluidBalanceChart] c ON c.[Id]=e.[FluidBalanceChartId]
                          WHERE c.[PatientId]=@CopyPat AND c.[Id] <> @FbcId) = 3
                    THEN 'PASS' ELSE '** FAIL - children still point at source **' END AS Result
        UNION ALL
        SELECT 'Med admins reference copied chart',
               CAST((SELECT COUNT(*) FROM [dbo].[MedicationRegularAdministration]
                     WHERE [PatientId]=@CopyPat AND [PatientMedicationChartId] <> @RegChartId) AS VARCHAR(20)) + ' of 2',
               CASE WHEN (SELECT COUNT(*) FROM [dbo].[MedicationRegularAdministration]
                          WHERE [PatientId]=@CopyPat AND [PatientMedicationChartId] <> @RegChartId) = 2
                    THEN 'PASS' ELSE '** FAIL - children still point at source **' END
        UNION ALL
        SELECT 'No child leaked onto source parent',
               CAST((SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] WHERE [FluidBalanceChartId]=@FbcId) AS VARCHAR(20)) + ' (expect 3)',
               CASE WHEN (SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] WHERE [FluidBalanceChartId]=@FbcId) = 3
                    THEN 'PASS' ELSE '** FAIL **' END
        UNION ALL
        SELECT 'Copied patient is module-owned (LabId 0)',
               ISNULL(CAST((SELECT [LabId] FROM [dbo].[Patient] WHERE [Id]=@CopyPat) AS VARCHAR(20)),'NULL'),
               CASE WHEN (SELECT [LabId] FROM [dbo].[Patient] WHERE [Id]=@CopyPat) = 0
                    THEN 'PASS' ELSE '** FAIL **' END
        UNION ALL
        SELECT 'NOT NULL LabId tables accepted the copy',
               CAST((SELECT COUNT(*) FROM [dbo].[BradenAssessment] WHERE [PatientId]=@CopyPat) AS VARCHAR(10)) + ' braden row(s)',
               CASE WHEN (SELECT COUNT(*) FROM [dbo].[BradenAssessment] WHERE [PatientId]=@CopyPat) = 1
                    THEN 'PASS' ELSE '** FAIL **' END
        UNION ALL
        SELECT 'Copied patient carries new ModuleId',
               CAST(@CopyModId AS VARCHAR(20)),
               CASE WHEN (SELECT [ModuleId] FROM [dbo].[Patient] WHERE [Id]=@CopyPat) = @CopyModId
                    THEN 'PASS' ELSE '** FAIL **' END
        UNION ALL
        SELECT 'Patient field values carried over',
               ISNULL((SELECT [UriNumber] FROM [dbo].[Patient] WHERE [Id]=@CopyPat),'(null)'),
               CASE WHEN (SELECT [UriNumber] FROM [dbo].[Patient] WHERE [Id]=@CopyPat) = 'URI-SMOKE'
                    THEN 'PASS' ELSE '** FAIL **' END
        UNION ALL
        SELECT 'Source and copy are distinct patients',
               CAST(@SrcPat AS VARCHAR(20)) + ' vs ' + CAST(@CopyPat AS VARCHAR(20)),
               CASE WHEN @SrcPat <> @CopyPat THEN 'PASS' ELSE '** FAIL **' END
    ) k;

    /* ---- 6. re-scoped procs return module patients (LabId = 0) ---------- */
    DECLARE @notes INT;
    CREATE TABLE #pn (Id INT, LabId INT, Notes NVARCHAR(MAX), Sign VARCHAR(50),
                      NotesDate DATETIME, PatientId INT, NotesFrom VARCHAR(10));
    INSERT INTO #pn EXEC [dbo].[GetProgressNotes] @LabId = 0, @PatientId = @CopyPat;
    SELECT @notes = COUNT(*) FROM #pn;

    SELECT 'C. Re-scoped proc' AS Test_,
           'GetProgressNotes @LabId=0 on module patient' AS Check_,
           CAST(@notes AS VARCHAR(10)) + ' of 2 rows' AS Detail_,
           CASE WHEN @notes = 2 THEN 'PASS'
                ELSE '** FAIL - Sprint3_03 sentinel not working **' END AS Result;
    DROP TABLE #pn;

    /* ---- 7. DeleteModule cascade ---------------------------------------- */
    EXEC [dbo].[DeleteModule] @ModuleId = @CopyModId;

    SELECT 'D. DeleteModule' AS Test_, Check_, Detail_, Result FROM (
        SELECT 'Module row removed' AS Check_,
               CAST((SELECT COUNT(*) FROM [dbo].[Module] WHERE [Id]=@CopyModId) AS VARCHAR(10)) AS Detail_,
               CASE WHEN NOT EXISTS (SELECT 1 FROM [dbo].[Module] WHERE [Id]=@CopyModId)
                    THEN 'PASS' ELSE '** FAIL **' END AS Result
        UNION ALL
        SELECT 'Copied patient removed',
               CAST((SELECT COUNT(*) FROM [dbo].[Patient] WHERE [ModuleId]=@CopyModId) AS VARCHAR(10)),
               CASE WHEN NOT EXISTS (SELECT 1 FROM [dbo].[Patient] WHERE [ModuleId]=@CopyModId)
                    THEN 'PASS' ELSE '** FAIL **' END
        UNION ALL
        SELECT 'Orphaned FBC entries left behind',
               CAST((SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] e
                     LEFT JOIN [dbo].[FluidBalanceChart] c ON c.[Id]=e.[FluidBalanceChartId]
                     WHERE c.[Id] IS NULL) AS VARCHAR(10)),
               CASE WHEN (SELECT COUNT(*) FROM [dbo].[FluidBalanceChartEntry] e
                          LEFT JOIN [dbo].[FluidBalanceChart] c ON c.[Id]=e.[FluidBalanceChartId]
                          WHERE c.[Id] IS NULL) = 0
                    THEN 'PASS' ELSE '** FAIL - orphans **' END
        UNION ALL
        SELECT 'Source module survived the delete',
               CAST((SELECT COUNT(*) FROM [dbo].[Patient] WHERE [ModuleId]=@SrcModId) AS VARCHAR(10)),
               CASE WHEN EXISTS (SELECT 1 FROM [dbo].[Module] WHERE [Id]=@SrcModId)
                    THEN 'PASS' ELSE '** FAIL - deleted too much **' END
    ) d;

END TRY
BEGIN CATCH
    SELECT 'ERROR' AS Test_,
           ERROR_NUMBER()  AS ErrNo,
           ERROR_PROCEDURE() AS Proc_,
           ERROR_LINE()    AS Line_,
           ERROR_MESSAGE() AS Message_;
END CATCH;

/* ALWAYS undo everything - the test leaves no trace. */
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

SELECT 'Rolled back - database unchanged. TranCount now ' + CAST(@@TRANCOUNT AS VARCHAR(5)) AS Cleanup_;
GO
