DECLARE @sScriptName VARCHAR(256) = N'PopulateDimUser.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

MERGE INTO dbo.DimUser AS Target 
USING 
(
	VALUES 
	(1, 'Matt Potter')
	--(2, 'Alan Potter')
)
AS Source (UserKey, UserName)
ON Target.UserKey = Source.UserKey
WHEN MATCHED THEN 
UPDATE SET UserName = Source.UserName
WHEN NOT MATCHED BY TARGET THEN 
INSERT (UserKey, UserName) 
VALUES (UserKey, UserName)  
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;
GO

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimUser.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO