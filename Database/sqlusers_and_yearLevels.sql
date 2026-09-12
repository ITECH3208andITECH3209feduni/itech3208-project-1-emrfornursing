SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Lab] WHERE [LabLogin] = 'lab123')
BEGIN
    INSERT INTO [dbo].[Lab] ([LabName], [Active], [LabLogin], [LabPassword])
    VALUES ('Berwick Lab', 1, 'lab123', 'lab123');

    PRINT 'Laboratory created: Berwick Lab - login lab123 / lab123';
END
ELSE
BEGIN
    PRINT 'Laboratory lab123 already exists - left alone.';
END

DECLARE @LabId INT =
    (SELECT TOP (1) [Id] FROM [dbo].[Lab] WHERE [LabLogin] = 'lab123' ORDER BY [Id]);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Supervisor] WHERE [UserLogin] = 'super')
BEGIN
    INSERT INTO [dbo].[Supervisor] ([UserName], [UserLogin], [UserPassword], [LabId])
    VALUES ('Supervisor Name', 'super', 'super', @LabId);

    PRINT 'Supervisor created: super - login super / super';
END
ELSE
BEGIN
    PRINT 'Supervisor super already exists - left alone.';
END
GO

INSERT INTO [dbo].[YearLevel] ([YearLevelName], [SortOrder], [Active], [CreatedDate])
SELECT v.Name, v.SortOrder, 1, GETDATE()
FROM   (VALUES ('Year 1 Nursing', 1),
               ('Year 2 Nursing', 2),
               ('Year 3 Nursing', 3)) AS v(Name, SortOrder)
WHERE  NOT EXISTS (SELECT 1 FROM [dbo].[YearLevel] y WHERE y.[YearLevelName] = v.Name);

PRINT 'Year levels added: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

DECLARE @Units TABLE (YearLevelName VARCHAR(50), UnitCode VARCHAR(20), SortOrder INT);

INSERT INTO @Units (YearLevelName, UnitCode, SortOrder) VALUES
    ('Year 1 Nursing', 'NURBN1104', 1),
    ('Year 1 Nursing', 'NURBN1108', 2),
    ('Year 2 Nursing', 'NURBN2104', 1),
    ('Year 2 Nursing', 'NURBN2108', 2),
    ('Year 3 Nursing', 'NURBN3104', 1),
    ('Year 3 Nursing', 'NURBN3108', 2);

INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder], [Active], [CreatedDate])
SELECT  y.[Id], u.UnitCode, u.UnitCode, u.SortOrder, 1, GETDATE()
FROM    @Units u
JOIN    [dbo].[YearLevel] y ON y.[YearLevelName] = u.YearLevelName
WHERE   NOT EXISTS (SELECT 1 FROM [dbo].[Unit] e
                    WHERE e.[YearLevelId] = y.[Id] AND e.[UnitCode] = u.UnitCode);

PRINT 'Units added: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

UPDATE [dbo].[Unit]
SET    [Active] = 0
WHERE  [UnitName] LIKE '%Unassigned%' AND [Active] = 1;

PRINT 'Placeholder units deactivated: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
GO

SELECT 'Laboratories' AS Item_, CAST(COUNT(*) AS VARCHAR(10)) AS Count_ FROM [dbo].[Lab]
UNION ALL SELECT 'Supervisors', CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Supervisor]
UNION ALL SELECT 'Year levels', CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[YearLevel]
UNION ALL SELECT 'Units',       CAST(COUNT(*) AS VARCHAR(10)) FROM [dbo].[Unit];

SELECT  y.[YearLevelName], u.[UnitCode], u.[UnitName], u.[Active]
FROM    [dbo].[Unit] u
JOIN    [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
ORDER BY y.[SortOrder], u.[Active] DESC, u.[SortOrder];
GO
