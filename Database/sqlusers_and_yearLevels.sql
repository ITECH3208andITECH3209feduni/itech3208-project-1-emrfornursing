SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Lab] WHERE [LabLogin] = 'lab123')
BEGIN
    INSERT INTO [dbo].[Lab] ([LabName], [Active], [LabLogin], [LabPassword])
    VALUES ('Berwick Lab', 1, 'lab123', 'lab123');

    PRINT 'New lab record added -> Berwick Lab (login lab123 / lab123)';
END
ELSE
BEGIN
    PRINT 'Lab login lab123 is already present - no changes made.';
END

DECLARE @ExistingLabId INT =
    (SELECT TOP (1) [Id] FROM [dbo].[Lab] WHERE [LabLogin] = 'lab123' ORDER BY [Id]);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Supervisor] WHERE [UserLogin] = 'super')
BEGIN
    INSERT INTO [dbo].[Supervisor] ([UserName], [UserLogin], [UserPassword], [LabId])
    VALUES ('Supervisor Name', 'super', 'super', @ExistingLabId);

    PRINT 'New supervisor added -> login super / super';
END
ELSE
BEGIN
    PRINT 'Supervisor login super is already present - no changes made.';
END
GO

INSERT INTO [dbo].[YearLevel] ([YearLevelName], [SortOrder], [Active], [CreatedDate])
SELECT src.Name, src.SortOrder, 1, GETDATE()
FROM   (VALUES ('Year 1 Nursing', 1),
               ('Year 2 Nursing', 2),
               ('Year 3 Nursing', 3)) AS src(Name, SortOrder)
WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[YearLevel] existingLevel WHERE existingLevel.[YearLevelName] = src.Name);

PRINT 'Year levels inserted this run: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

DECLARE @UnitSeedRows TABLE (YearLevelName VARCHAR(50), UnitCode VARCHAR(20), SortOrder INT);

INSERT INTO @UnitSeedRows (YearLevelName, UnitCode, SortOrder) VALUES
    ('Year 1 Nursing', 'NURBN1104', 1),
    ('Year 1 Nursing', 'NURBN1108', 2),
    ('Year 2 Nursing', 'NURBN2104', 1),
    ('Year 2 Nursing', 'NURBN2108', 2),
    ('Year 3 Nursing', 'NURBN3104', 1),
    ('Year 3 Nursing', 'NURBN3108', 2);

INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder], [Active], [CreatedDate])
SELECT  level.[Id], seed.UnitCode, seed.UnitCode, seed.SortOrder, 1, GETDATE()
FROM    @UnitSeedRows seed
JOIN    [dbo].[YearLevel] level ON level.[YearLevelName] = seed.YearLevelName
WHERE   NOT EXISTS (SELECT 1 FROM [dbo].[Unit] existingUnit
                    WHERE existingUnit.[YearLevelId] = level.[Id] AND existingUnit.[UnitCode] = seed.UnitCode);

PRINT 'Units inserted this run: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

UPDATE [dbo].[Unit]
SET    [Active] = 0
WHERE  [UnitName] LIKE '%Unassigned%' AND [Active] = 1;

PRINT 'Placeholder units turned inactive: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

SELECT 'Laboratories' AS Item_, CAST(COUNT(*) AS VARCHAR(10)) AS Count_ FROM [dbo].[Lab]
UNION ALL SELECT 'Supervisors', CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Supervisor]
UNION ALL SELECT 'Year levels', CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[YearLevel]
UNION ALL SELECT 'Units',       CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Unit];

SELECT  level.[YearLevelName], unitRow.[UnitCode], unitRow.[UnitName], unitRow.[Active]
FROM    [dbo].[Unit] unitRow
JOIN    [dbo].[YearLevel] level ON level.[Id] = unitRow.[YearLevelId]
ORDER BY level.[SortOrder], unitRow.[Active] DESC, unitRow.[SortOrder];
GO
