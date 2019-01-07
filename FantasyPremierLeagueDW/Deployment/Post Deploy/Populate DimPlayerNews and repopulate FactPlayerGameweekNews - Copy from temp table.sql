DECLARE @sScriptName VARCHAR(256) = N'Populate DimPlayerNews and repopulate FactPlayerGameweekNews - Copy from temp table.sql';
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
	AND  TABLE_NAME = 'FactPlayerGameweekNewsTemp'
)
BEGIN
    
	RAISERROR('*** Processing...' , 0, 1) WITH NOWAIT;

	BEGIN TRANSACTION;
	
	INSERT INTO dbo.DimPlayerNews
	(News, CreatedDate)
	SELECT News,
	MIN(gw.DeadlineTime) AS CreatedDate
	FROM dbo.FactPlayerGameweekNewsTemp fpgn
	INNER JOIN dbo.DimGameweek gw
	ON fpgn.SeasonKey = gw.SeasonKey
	AND fpgn.GameweekKey = gw.GameweekKey
	GROUP BY News
	ORDER BY CreatedDate;

	INSERT INTO dbo.FactPlayerGameweekNews
	(PlayerKey, SeasonKey, GameweekKey, TeamKey, FactPlayerGameweekStatusKey, PlayerNewsKey)
    SELECT PlayerKey,
           SeasonKey,
           GameweekKey,
           TeamKey,
           FactPlayerGameweekStatusKey,
		   PlayerNewsKey
    FROM dbo.FactPlayerGameweekNewsTemp pgn
	INNER JOIN dbo.DimPlayerNews pn
	ON pgn.News = pn.News
    ORDER BY PlayerKey ASC, SeasonKey ASC, GameweekKey ASC;

	DROP TABLE dbo.FactPlayerGameweekNewsTemp;

	COMMIT TRANSACTION;

END
ELSE
BEGIN

	RAISERROR('*** No code executed...' , 0, 1) WITH NOWAIT;

END
GO

DECLARE @sScriptName VARCHAR(256) = N'Populate DimPlayerNews and repopulate FactPlayerGameweekNews - Copy from temp table.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO