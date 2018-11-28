DECLARE @sScriptName VARCHAR(256) = N'PopulateDimUserTeam.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

SET IDENTITY_INSERT dbo.DimUserTeam ON;

MERGE INTO dbo.DimUserTeam AS Target 
USING 
(
	VALUES 
	(1, 1, 12, 'The Rhodes 2 Victory', '')
	--(2, 1, 12 'Second team', '')
)
AS Source (UserTeamKey, UserKey, SeasonKey, UserTeamName, UserTeamDescription)
ON Target.UserTeamKey = Source.UserTeamKey
WHEN MATCHED THEN 
UPDATE SET UserKey = Source.UserKey,
		   SeasonKey = Source.SeasonKey,
		   UserTeamName = Source.UserTeamName,
		   UserTeamDescription = Source.UserTeamDescription
WHEN NOT MATCHED BY TARGET THEN 
INSERT (UserTeamKey, UserKey, SeasonKey, UserTeamName, UserTeamDescription) 
VALUES (Source.UserTeamKey, Source.UserKey, Source.SeasonKey, Source.UserTeamName, Source.UserTeamDescription);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;
GO

SET IDENTITY_INSERT dbo.DimUserTeam OFF;

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimUserTeam.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO