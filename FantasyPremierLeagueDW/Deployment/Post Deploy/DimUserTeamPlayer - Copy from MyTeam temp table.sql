DECLARE @sScriptName VARCHAR(256) = N'DimUserTeamPlayer - Copy from MyTeam temp table.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

IF EXISTS 
(
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo' 
	AND  TABLE_NAME = 'DimUserTeamPlayerTemp'
)
BEGIN
    
	RAISERROR('*** Processing...' , 0, 1) WITH NOWAIT;
	
	INSERT INTO dbo.DimUserTeamPlayer
	SELECT 1 AS UserTeamKey,
	*
	FROM dbo.DimUserTeamPlayerTemp;

	DROP TABLE dbo.MyTeam;
	DROP TABLE dbo.DimUserTeamPlayerTemp;

END
ELSE
BEGIN

	RAISERROR('*** No code executed...' , 0, 1) WITH NOWAIT;

END
GO

DECLARE @sScriptName VARCHAR(256) = N'DimUserTeamPlayer - Copy from MyTeam temp table.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO