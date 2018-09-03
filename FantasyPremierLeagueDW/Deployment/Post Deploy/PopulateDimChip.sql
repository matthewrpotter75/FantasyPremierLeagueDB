DECLARE @sScriptName VARCHAR(256) = N'PopulateDimChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

MERGE INTO dbo.DimChip AS Target 
USING 
(
	VALUES 
	(1, 'Wildcard'),
	(2, 'Bench Boost'),
	(3, 'Free Hit'),
	(4, 'Triple Captain')
)
AS Source (ChipKey, ChipName)
ON Target.ChipKey = Source.ChipKey
WHEN MATCHED THEN 
UPDATE SET ChipName = Source.ChipName
WHEN NOT MATCHED BY TARGET THEN 
INSERT (ChipKey, ChipName) 
VALUES (ChipKey, ChipName)  
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;
GO

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO