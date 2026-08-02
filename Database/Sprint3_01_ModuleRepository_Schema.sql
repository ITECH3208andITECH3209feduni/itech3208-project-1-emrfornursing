/* ============================================================================
   ITECH3208 EMR Simulator - Sprint 3
   Requirement 1: Global Module Repository & Year-Level Management
   Part 01 of 03 - Schema (tables, columns, indexes, seed data)

   Target database : EmrSimulator
   Run order       : 01_Schema  ->  02_ModuleProcs  ->  03_RescopeExistingProcs
   Idempotent      : yes - safe to re-run, will not duplicate or drop data

   ---------------------------------------------------------------------------
   DESIGN NOTE
   ---------------------------------------------------------------------------
   Existing model:  Lab (campus) -> Patient -> 21 clinical tables
                    Every clinical table carries both LabId and PatientId.

   New model:       YearLevel -> Unit -> Module -> Patient -> 21 clinical tables

   A Module owns its own Patient rows. Modules live in a single GLOBAL
   repository shared by all three campus Supervisor logins, so module-owned
   rows carry LabId = 0 and a set ModuleId.

   LabId 0 rather than NULL: dbo.Lab.Id is IDENTITY(1,1) so 0 never matches a
   real lab, and four tables (BradenAssessment, FallRiskAssessments,
   FoodIntakeHeader, RiskmanIncident) declare LabId NOT NULL and would reject
   NULL outright.

   Clinical charts are NOT modified. They already hang off PatientId, and
   because each module has its own Patient rows, PatientId alone scopes a
   chart correctly. Script 03 makes the LabId predicate optional on the
   existing read procedures so module-owned patients resolve.

   Unlike the Sprint 1/2 tables, the new tables DO declare foreign keys.
   They are confined to the new subtree, so no existing behaviour changes.
   ============================================================================ */

USE [EmrSimulator];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* ---------------------------------------------------------------------------
   1. YearLevel
   e.g. "Year 1 Nursing", "Year 2 Nursing", "Year 3 Nursing"
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'YearLevel' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[YearLevel](
        [Id]            INT IDENTITY(1,1) NOT NULL,
        [YearLevelName] VARCHAR(50)       NOT NULL,
        [SortOrder]     INT               NOT NULL CONSTRAINT DF_YearLevel_SortOrder DEFAULT (0),
        [Active]        BIT               NOT NULL CONSTRAINT DF_YearLevel_Active    DEFAULT (1),
        [CreatedDate]   DATETIME          NOT NULL CONSTRAINT DF_YearLevel_Created   DEFAULT (GETDATE()),
        CONSTRAINT [PK_YearLevel] PRIMARY KEY CLUSTERED ([Id] ASC)
    );
    PRINT 'Created table dbo.YearLevel';
END
ELSE
    PRINT 'Table dbo.YearLevel already exists - skipped';
GO

/* ---------------------------------------------------------------------------
   2. Unit
   A unit of study within a year level, e.g. "NURBN2019 Clinical Practice 2"
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Unit' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Unit](
        [Id]          INT IDENTITY(1,1) NOT NULL,
        [YearLevelId] INT               NOT NULL,
        [UnitCode]    VARCHAR(20)       NULL,
        [UnitName]    VARCHAR(100)      NOT NULL,
        [SortOrder]   INT               NOT NULL CONSTRAINT DF_Unit_SortOrder DEFAULT (0),
        [Active]      BIT               NOT NULL CONSTRAINT DF_Unit_Active    DEFAULT (1),
        [CreatedDate] DATETIME          NOT NULL CONSTRAINT DF_Unit_Created    DEFAULT (GETDATE()),
        CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_Unit_YearLevel] FOREIGN KEY ([YearLevelId])
            REFERENCES [dbo].[YearLevel]([Id])
    );
    CREATE NONCLUSTERED INDEX [IX_Unit_YearLevelId] ON [dbo].[Unit]([YearLevelId] ASC);
    PRINT 'Created table dbo.Unit';
END
ELSE
    PRINT 'Table dbo.Unit already exists - skipped';
GO

/* ---------------------------------------------------------------------------
   3. Module
   A single laboratory scenario, e.g. "Week 2 - Post-operative care".
   Global: not owned by any Lab / Supervisor account.
   CreatedBySupervisorId is recorded for audit only, never used for filtering.
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Module' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Module](
        [Id]                    INT IDENTITY(1,1) NOT NULL,
        [UnitId]                INT               NOT NULL,
        [ModuleName]            VARCHAR(150)      NOT NULL,
        [Description]           NVARCHAR(500)     NULL,
        [SortOrder]             INT               NOT NULL CONSTRAINT DF_Module_SortOrder DEFAULT (0),
        [Active]                BIT               NOT NULL CONSTRAINT DF_Module_Active    DEFAULT (1),
        [CreatedBySupervisorId] INT               NULL,
        [CreatedDate]           DATETIME          NOT NULL CONSTRAINT DF_Module_Created    DEFAULT (GETDATE()),
        [UpdatedDate]           DATETIME          NULL,
        CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_Module_Unit] FOREIGN KEY ([UnitId])
            REFERENCES [dbo].[Unit]([Id])
    );
    CREATE NONCLUSTERED INDEX [IX_Module_UnitId] ON [dbo].[Module]([UnitId] ASC);
    PRINT 'Created table dbo.Module';
END
ELSE
    PRINT 'Table dbo.Module already exists - skipped';
GO

/* ---------------------------------------------------------------------------
   4. Patient.ModuleId
   NULL  = legacy lab-owned patient (all Sprint 1/2 data). Behaviour unchanged.
   Set   = module-owned patient in the global repository (its LabId will be 0).
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.Patient') AND name = 'ModuleId')
BEGIN
    ALTER TABLE [dbo].[Patient] ADD [ModuleId] INT NULL;
    PRINT 'Added column dbo.Patient.ModuleId';
END
ELSE
    PRINT 'Column dbo.Patient.ModuleId already exists - skipped';
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Patient_Module')
BEGIN
    ALTER TABLE [dbo].[Patient] WITH NOCHECK
        ADD CONSTRAINT [FK_Patient_Module] FOREIGN KEY ([ModuleId])
        REFERENCES [dbo].[Module]([Id]);
    PRINT 'Added FK_Patient_Module';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Patient_ModuleId' AND object_id = OBJECT_ID('dbo.Patient'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Patient_ModuleId] ON [dbo].[Patient]([ModuleId] ASC);
    PRINT 'Created index IX_Patient_ModuleId';
END
GO

/* ---------------------------------------------------------------------------
   5. Seed data
   Three year levels and one placeholder unit each, so the Supervisor UI has
   something to render before any academic content exists.
   Guarded: only inserts when YearLevel is completely empty.
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM [dbo].[YearLevel])
BEGIN
    INSERT INTO [dbo].[YearLevel] ([YearLevelName], [SortOrder])
    VALUES ('Year 1 Nursing', 1),
           ('Year 2 Nursing', 2),
           ('Year 3 Nursing', 3);

    INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder])
    SELECT [Id], NULL, [YearLevelName] + ' - Unassigned', 1
    FROM [dbo].[YearLevel];

    PRINT 'Seeded 3 year levels and 3 placeholder units';
END
ELSE
    PRINT 'YearLevel already populated - seed skipped';
GO

PRINT '=== Sprint3 Part 01 (Schema) complete ===';
GO
