DECLARE @sScriptName VARCHAR(256) = N'DimUserTeamPlayer - Copy MyTeam into temp table.sql';
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
	AND  TABLE_NAME = 'DimUserTeamPlayer'
)
AND EXISTS 
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo' 
	AND  TABLE_NAME = 'MyTeam'
)
BEGIN

	RAISERROR('*** Processing...' , 0, 1) WITH NOWAIT;

	IF EXISTS 
	(
		SELECT * 
		FROM INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_SCHEMA = 'dbo' 
		AND  TABLE_NAME = 'DimUserTeamPlayerTemp'
	)
	DROP TABLE dbo.DimUserTeamPlayerTemp;
    
	SELECT *
	INTO dbo.DimUserTeamPlayerTemp	
	FROM dbo.MyTeam;

END
ELSE
BEGIN

	RAISERROR('*** No code executed...' , 0, 1) WITH NOWAIT;

END

GO

DECLARE @sScriptName VARCHAR(256) = N'DimUserTeamPlayer - Copy MyTeam into temp table.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO