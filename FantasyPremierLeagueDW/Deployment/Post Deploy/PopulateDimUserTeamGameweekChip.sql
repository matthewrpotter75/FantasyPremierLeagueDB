DECLARE @sScriptName VARCHAR(256) = N'PopulateDimUserTeamGameweekChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

MERGE INTO dbo.DimUserTeamGameweekChip AS Target 
USING 
(
	VALUES 
	(1, 1, 12, 4),
	(1, 3, 12, 31),
	(1, 1, 12, 33),
	(1, 2, 12, 34),
	(1, 4, 12, 37)
	
)
AS Source (UserTeamKey, ChipKey, SeasonKey, GameweekKey)
ON Target.UserTeamKey = Source.UserTeamKey
AND Target.ChipKey = Source.ChipKey
AND Target.SeasonKey = Source.SeasonKey
AND Target.GameweekKey = Source.GameweekKey
WHEN NOT MATCHED BY TARGET THEN 
INSERT (UserTeamKey, ChipKey, GameweekKey, SeasonKey) 
VALUES (Source.UserTeamKey, Source.ChipKey, Source.GameweekKey, Source.SeasonKey);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;
GO

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimUserTeamGameweekChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO