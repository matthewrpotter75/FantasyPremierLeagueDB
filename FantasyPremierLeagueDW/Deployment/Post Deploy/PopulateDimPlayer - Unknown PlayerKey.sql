DECLARE @sScriptName VARCHAR(256) = N'PopulateDimPlayer - Unknown PlayerKey.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

SET IDENTITY_INSERT dbo.DimPlayer ON;

MERGE INTO dbo.DimPlayer AS Target 
USING 
(
	VALUES 
	(-1, 'Unknown', 'Unknown', 'Unknown', 'Unknown')
)
AS Source (PlayerKey, FirstName, SecondName, WebName, PlayerName)
ON Target.PlayerKey = Source.PlayerKey
WHEN NOT MATCHED BY TARGET THEN 
INSERT (PlayerKey, FirstName, SecondName, WebName, PlayerName)
VALUES (Source.PlayerKey, Source.FirstName, Source.SecondName, Source.WebName, Source.PlayerName);
GO

SET IDENTITY_INSERT dbo.DimPlayer OFF;

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimPlayer - Unknown PlayerKey';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO