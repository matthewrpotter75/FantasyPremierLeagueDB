DECLARE @sScriptName VARCHAR(256) = N'Update FactPlayerNews to have PlayerNewsKey - Copy FactPlayerNews into temp table.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

IF NOT EXISTS 
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo' 
	AND  TABLE_NAME = 'DimPlayerNews'
)
BEGIN

	RAISERROR('*** Processing...' , 0, 1) WITH NOWAIT;

	IF EXISTS 
	(
		SELECT * 
		FROM INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_SCHEMA = 'dbo' 
		AND  TABLE_NAME = 'FactPlayerGameweekNewsTemp'
	)
	DROP TABLE dbo.FactPlayerGameweekNewsTemp;
    
	SELECT *
	INTO dbo.FactPlayerGameweekNewsTemp	
	FROM dbo.FactPlayerGameweekNews;

	TRUNCATE TABLE dbo.FactPlayerGameweekNews;

END
ELSE
BEGIN

	RAISERROR('*** No code executed...' , 0, 1) WITH NOWAIT;

END

GO

DECLARE @sScriptName VARCHAR(256) = N'Update FactPlayerNews to have PlayerNewsKey - Copy FactPlayerNews into temp table.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO