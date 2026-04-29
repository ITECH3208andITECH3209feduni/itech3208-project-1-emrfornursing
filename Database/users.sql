-- This will be used by the student to log in using login: lab123, password: lab123
-- Insert a new record in the Lab table
DECLARE @LabId INT;
INSERT INTO Lab (LabName, Active, LabLogin, LabPassword)
VALUES ('Berwick Lab', 1, 'lab123', ' lab123');
-- Retrieve the newly inserted Lab ID
SET @LabId = SCOPE_IDENTITY();
-- This will be used by the Supervisor to log in using login: super, password: super
-- Insert a new record in the Supervisor table using the LabId as a foreign key
INSERT INTO Supervisor (UserName, UserLogin, UserPassword, LabId)
VALUES ('Supervisor Name', 'super', 'super', @LabId);