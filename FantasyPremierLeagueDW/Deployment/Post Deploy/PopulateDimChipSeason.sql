DECLARE @sScriptName VARCHAR(256) = N'PopulateDimChipSeason.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

MERGE INTO dbo.DimChipSeason AS Target 
USING 
(
	VALUES 
	(1, 12),
	(2, 12),
	(3, 12),
	(4, 12)
)
AS Source (ChipKey, SeasonKey)
ON Target.ChipKey = Source.ChipKey
WHEN NOT MATCHED BY TARGET THEN 
INSERT (ChipKey, SeasonKey) 
VALUES (ChipKey, SeasonKey)  
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;
GO

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimChipSeason.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO