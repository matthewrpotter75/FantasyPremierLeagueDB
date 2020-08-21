DECLARE @sScriptName VARCHAR(256) = N'PopulateChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

MERGE INTO dbo.Chip AS Target 
USING 
(
	VALUES 
	(1, 'wildcard','Wildcard'),
	(2, 'bboost','Bench Boost'),
	(3, 'freehit','Free Hit'),
	(4, '3xc','Triple Captain')
)
AS Source (chipid, chipname, chipdesc)
ON Target.chipid = Source.chipid
WHEN MATCHED THEN 
UPDATE SET chipname = Source.chipname, chipdesc = Source.chipdesc
WHEN NOT MATCHED BY TARGET THEN 
INSERT (chipid, chipname, chipdesc) 
VALUES (chipid, chipname, chipdesc)  
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;
GO

DECLARE @sScriptName VARCHAR(256) = N'PopulateChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO


DECLARE @sScriptName VARCHAR(256) = N'PopulateDimChip.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO