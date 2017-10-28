CREATE PROCEDURE dbo.GetPossibleTeamPlayerPointsForGameweekPeriod
(
	@SeasonKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

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

	DECLARE @colHeaders VARCHAR(200);

	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	IF @Debug = 1
		SELECT @colHeaders;

	DECLARE @sql NVARCHAR(2000);
	
	--SET @sql = 'DECLARE @CurrentGameweekKey INT;
	--SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE();

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT pt.PlayerKey,
		p.PlayerName, 
		pt.GameweekKey, 
		pp.PlayerPositionKey,
		pp.PlayerPositionShort,
		pt.Cost,
		ph.TotalPoints
		FROM dbo.PossibleTeam pt
		INNER JOIN dbo.DimPlayer p
		ON pt.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory ph
		ON pt.PlayerKey = ph.PlayerKey
		AND pt.SeasonKey = ph.SeasonKey
		AND pt.GameweekKey = ph.GameweekKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	)
	SELECT PlayerName, PlayerPositionShort, Cost, ' + @colHeaders + '
	FROM
	(
		SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, Cost, PlayerPositionKey, GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv
	ORDER BY PlayerPositionKey, PlayerKey;';

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT, @GameweekStart INT, @GameweekEnd INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @GameweekStart = @GameweekStart, @GameweekEnd = @GameweekEnd;

END