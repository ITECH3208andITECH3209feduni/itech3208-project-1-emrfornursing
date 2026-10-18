USE [EmrSimulator];
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* Sprint 5 uses separate tables so the legacy PRN and REGULAR tables are unchanged.
       Re-running this script recreates only the Sprint 5 tables. */
    IF OBJECT_ID('dbo.S5MedicationAdministration', 'U') IS NOT NULL DROP TABLE dbo.S5MedicationAdministration;
    IF OBJECT_ID('dbo.S5MedicationSchedule', 'U') IS NOT NULL DROP TABLE dbo.S5MedicationSchedule;
    IF OBJECT_ID('dbo.S5MedicationOrder', 'U') IS NOT NULL DROP TABLE dbo.S5MedicationOrder;

    CREATE TABLE dbo.S5MedicationOrder
    (
        Id                    INT IDENTITY(1,1) NOT NULL,
        LabId                 INT NOT NULL,
        PatientId             INT NOT NULL,
        MedicationType        VARCHAR(10) NOT NULL,
        MedicationName        NVARCHAR(200) NOT NULL,
        Strength              NVARCHAR(100) NOT NULL,
        Route                 NVARCHAR(100) NOT NULL,
        Frequency             NVARCHAR(100) NOT NULL,
        MaximumDose           NVARCHAR(120) NOT NULL,
        Indication            NVARCHAR(500) NOT NULL,
        PrescriberName        NVARCHAR(200) NOT NULL,
        PrescriberSignature   NVARCHAR(200) NOT NULL,
        StartDate             DATE NOT NULL,
        EndDate               DATE NULL,
        Status                VARCHAR(20) NOT NULL CONSTRAINT DF_S5MedicationOrder_Status DEFAULT ('Active'),
        DiscontinuedAt        DATETIME2 NULL,
        DiscontinuedBy        NVARCHAR(200) NULL,
        CreatedAt             DATETIME2 NOT NULL CONSTRAINT DF_S5MedicationOrder_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt             DATETIME2 NOT NULL CONSTRAINT DF_S5MedicationOrder_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_S5MedicationOrder PRIMARY KEY (Id),
        CONSTRAINT CK_S5MedicationOrder_Type CHECK (MedicationType IN ('Regular','PRN','STAT')),
        CONSTRAINT CK_S5MedicationOrder_Status CHECK (Status IN ('Active','Discontinued')),
        CONSTRAINT CK_S5MedicationOrder_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate)
    );

    CREATE INDEX IX_S5MedicationOrder_Patient
        ON dbo.S5MedicationOrder (LabId, PatientId, MedicationType, Status);

    CREATE TABLE dbo.S5MedicationSchedule
    (
        Id                  INT IDENTITY(1,1) NOT NULL,
        MedicationOrderId   INT NOT NULL,
        ScheduledHour       TINYINT NOT NULL,
        CONSTRAINT PK_S5MedicationSchedule PRIMARY KEY (Id),
        CONSTRAINT FK_S5MedicationSchedule_Order FOREIGN KEY (MedicationOrderId)
            REFERENCES dbo.S5MedicationOrder(Id) ON DELETE CASCADE,
        CONSTRAINT CK_S5MedicationSchedule_Hour CHECK (ScheduledHour BETWEEN 0 AND 23),
        CONSTRAINT UQ_S5MedicationSchedule_OrderHour UNIQUE (MedicationOrderId, ScheduledHour)
    );

    CREATE TABLE dbo.S5MedicationAdministration
    (
        Id                    INT IDENTITY(1,1) NOT NULL,
        MedicationOrderId     INT NOT NULL,
        LabId                  INT NOT NULL,
        PatientId              INT NOT NULL,
        AdministrationDate    DATE NOT NULL,
        AdministrationHour    TINYINT NOT NULL,
        Status                 VARCHAR(20) NOT NULL,
        Dose                   NVARCHAR(100) NOT NULL CONSTRAINT DF_S5MedicationAdministration_Dose DEFAULT (''),
        GivenBy                NVARCHAR(200) NOT NULL,
        CoSign                 NVARCHAR(200) NOT NULL,
        Notes                  NVARCHAR(1000) NOT NULL CONSTRAINT DF_S5MedicationAdministration_Notes DEFAULT (''),
        AdministeredAt         DATETIME2 NOT NULL CONSTRAINT DF_S5MedicationAdministration_AdministeredAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_S5MedicationAdministration PRIMARY KEY (Id),
        CONSTRAINT FK_S5MedicationAdministration_Order FOREIGN KEY (MedicationOrderId)
            REFERENCES dbo.S5MedicationOrder(Id),
        CONSTRAINT CK_S5MedicationAdministration_Hour CHECK (AdministrationHour BETWEEN 0 AND 23),
        CONSTRAINT CK_S5MedicationAdministration_Status CHECK (Status IN ('Given','Held','Missed')),
        CONSTRAINT UQ_S5MedicationAdministration_OrderDateHour UNIQUE (MedicationOrderId, AdministrationDate, AdministrationHour)
    );

    CREATE INDEX IX_S5MedicationAdministration_PatientDate
        ON dbo.S5MedicationAdministration (LabId, PatientId, AdministrationDate, AdministrationHour);

    COMMIT TRANSACTION;
    PRINT 'Sprint 5 Medication Chart schema created successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

/* Verify the required Sprint 5 objects and columns were created. */
IF OBJECT_ID('dbo.S5MedicationOrder', 'U') IS NULL THROW 51001, 'S5MedicationOrder was not created.', 1;
IF OBJECT_ID('dbo.S5MedicationSchedule', 'U') IS NULL THROW 51002, 'S5MedicationSchedule was not created.', 1;
IF OBJECT_ID('dbo.S5MedicationAdministration', 'U') IS NULL THROW 51003, 'S5MedicationAdministration was not created.', 1;

IF COL_LENGTH('dbo.S5MedicationOrder', 'Strength') IS NULL THROW 51004, 'Missing Strength column.', 1;
IF COL_LENGTH('dbo.S5MedicationOrder', 'MaximumDose') IS NULL THROW 51005, 'Missing MaximumDose column.', 1;
IF COL_LENGTH('dbo.S5MedicationOrder', 'Indication') IS NULL THROW 51006, 'Missing Indication column.', 1;
IF COL_LENGTH('dbo.S5MedicationOrder', 'PrescriberSignature') IS NULL THROW 51007, 'Missing PrescriberSignature column.', 1;
IF COL_LENGTH('dbo.S5MedicationSchedule', 'ScheduledHour') IS NULL THROW 51008, 'Missing ScheduledHour column.', 1;
IF COL_LENGTH('dbo.S5MedicationAdministration', 'CoSign') IS NULL THROW 51009, 'Missing CoSign column.', 1;

PRINT 'SPRINT 5 DATABASE VERIFIED';
GO
