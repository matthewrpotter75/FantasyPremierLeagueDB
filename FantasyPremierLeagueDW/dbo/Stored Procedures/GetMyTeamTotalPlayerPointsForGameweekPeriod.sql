CREATE PROCEDURE dbo.GetMyTeamTotalPlayerPointsForGameweekPeriod
(
	@SeasonKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @colHeaders VARCHAR(25);
	DECLARE @sql NVARCHAR(4000);
	DECLARE @ParmDefinition NVARCHAR(500);

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek
	WHERE GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	ORDER BY GameweekKey;

	IF @Debug = 1
	BEGIN
		SELECT *
		FROM @Gameweeks;
	END	

	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	SELECT dp.PlayerKey,
	dp.PlayerName, 
	dpa.PlayerPositionKey,
	dpp.PlayerPositionShort,
	COUNT(DISTINCT fph.GameweekFixtureKey) AS TotalGames,
	SUM(fph.TotalPoints) AS TotalPoints
	FROM dbo.MyTeam my
	INNER JOIN dbo.DimPlayer dp
	ON my.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON my.PlayerKey = dpa.PlayerKey
	AND dpa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimPlayerPosition dpp
	ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
	INNER JOIN dbo.FactPlayerHistory fph
	ON dp.PlayerKey = fph.PlayerKey
	AND my.GameweekKey = fph.GameweekKey
	WHERE fph.SeasonKey = @SeasonKey
	AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	AND my.IsPlay = 1
	GROUP BY dp.PlayerKey, dp.PlayerName, dpa.PlayerPositionKey, dpp.PlayerPositionShort
	ORDER BY PlayerPositionKey, PlayerKey, TotalPoints DESC;

	--Player Points by Player Position
	SELECT 'Player Points by Player Position';

	;WITH PlayerPoints AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		COUNT(DISTINCT fph.GameweekFixtureKey) AS TotalGames,
		SUM(fph.TotalPoints) AS TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND my.IsPlay = 1
		GROUP BY dp.PlayerKey, dp.PlayerName, dpa.PlayerPositionKey, dpp.PlayerPositionShort
	)
	SELECT PlayerPositionKey, 
	PlayerPositionShort,
	SUM(TotalGames) AS TotalGames,
	SUM(TotalPoints) AS TotalPoints
	FROM PlayerPoints
	GROUP BY PlayerPositionKey, PlayerPositionShort
	ORDER BY PlayerPositionKey, PlayerPositionShort;

	--Player Points by Player Position and Gameweek
	SELECT 'Player Points by Player Position and Gameweek';

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		fph.GameweekKey,
		fph.TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND my.IsPlay = 1
	)
	SELECT PlayerPositionShort AS PlayerPosition, ' + @colHeaders + '
	FROM
	(
		SELECT DISTINCT PlayerPositionShort, PlayerPositionKey, GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv';

	IF @Debug=1
		PRINT @sql;

	SET @ParmDefinition = N'@SeasonKey INT, @GameweekStart INT, @GameweekEnd INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @GameweekStart = @GameweekStart, @GameweekEnd = @GameweekEnd;

	--Player Bench Points by Player Position and Gameweek
	SELECT 'Player Bench Points by Player Position and Gameweek';

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		fph.GameweekKey,
		fph.TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND my.IsPlay = 0
	)
	SELECT PlayerPositionShort AS PlayerPosition, ' + @colHeaders + '
	FROM
	(
		SELECT DISTINCT PlayerPositionShort, PlayerPositionKey, GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv';

	IF @Debug=1
		PRINT @sql;

	SET @ParmDefinition = N'@SeasonKey INT, @GameweekStart INT, @GameweekEnd INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @GameweekStart = @GameweekStart, @GameweekEnd = @GameweekEnd;

	--Player Points by Gameweek
	SELECT 'Player Points by Gameweek';

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		fph.GameweekKey,
		fph.TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND my.IsPlay = 1
	)
	SELECT ' + @colHeaders + '
	FROM
	(
		SELECT GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv';

	IF @Debug=1
		PRINT @sql;

	SET @ParmDefinition = N'@SeasonKey INT, @GameweekStart INT, @GameweekEnd INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @GameweekStart = @GameweekStart, @GameweekEnd = @GameweekEnd;

	--Total Points
	;WITH PlayerPoints AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		COUNT(DISTINCT fph.GameweekFixtureKey) AS TotalGames,
		SUM(fph.TotalPoints) AS TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND my.IsPlay = 1
		GROUP BY dp.PlayerKey, dp.PlayerName, dpa.PlayerPositionKey, dpp.PlayerPositionShort
	)
	SELECT SUM(TotalPoints) AS TotalPoints
	FROM PlayerPoints;

	--Total Bench Points
	;WITH BenchPoints AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		COUNT(DISTINCT fph.GameweekFixtureKey) AS TotalGames,
		SUM(fph.TotalPoints) AS TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND my.IsPlay = 0
		GROUP BY dp.PlayerKey, dp.PlayerName, dpa.PlayerPositionKey, dpp.PlayerPositionShort
	)
	SELECT SUM(TotalPoints) AS BenchPoints
	FROM BenchPoints;

END;