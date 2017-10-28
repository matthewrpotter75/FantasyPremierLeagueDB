CREATE PROCEDURE dbo.GetTeamPlayerPointsAndMinutesForGameweeksInSeason
(
	@SeasonKey INT = NULL,
	@TeamKey INT = NULL,
	@TeamShortName VARCHAR(3)= NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @TeamKey IS NULL
	BEGIN
		SELECT @TeamKey = TeamKey FROM dbo.DimTeam WHERE TeamShortName = @TeamShortName;
	END

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek gw
	WHERE EXISTS
	(
		SELECT 1
		FROM dbo.FactPlayerHistory
		WHERE SeasonKey = gw.SeasonKey
		AND GameweekKey = gw.GameweekKey
	)
	AND SeasonKey = @SeasonKey
	ORDER BY GameweekKey;

	IF @Debug = 1
	BEGIN
		SELECT *
		FROM @Gameweeks;
	END

	DECLARE @colHeaders VARCHAR(400);

	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	IF @Debug = 1
		SELECT @colHeaders;

	DECLARE @sql NVARCHAR(4000);
	
	--SET @sql = 'DECLARE @CurrentGameweekKey INT;
	--SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE();

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		ph.GameweekKey, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pcs.Cost,
		SUM(ph.TotalPoints) AS TotalPoints,
		SUM(ph.[Minutes]) AS TotalMinutes
		FROM dbo.DimPlayer p
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory ph
		ON p.PlayerKey = ph.PlayerKey
		INNER JOIN dbo.DimPlayerTeamGameweekFixture ptgf
		ON ph.PlayerKey = ptgf.PlayerKey
		AND ph.GameweekFixtureKey = ptgf.GameweekFixtureKey
		AND ph.WasHome = ptgf.IsHome
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON p.PlayerKey = pcs.PlayerKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ptgf.TeamKey = @TeamKey
		GROUP BY p.PlayerKey,
		p.PlayerName, 
		ph.GameweekKey, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pcs.Cost 
	),
	PlayerTotalPoints AS
	(
		SELECT PlayerKey,
		PlayerPositionKey,
		SUM(TotalPoints) AS TotalPoints,
		SUM(TotalMinutes) AS TotalMinutes
		FROM PlayerGameweekPoints
		GROUP BY PlayerKey, PlayerPositionKey
	),
	PlayerGameweekPivot AS
	(
		SELECT PlayerName, PlayerKey, PlayerPositionShort, Cost, ' + @colHeaders + '
		FROM
		(
			SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, Cost, GameweekKey, CAST(TotalPoints AS VARCHAR(3)) + '' ('' + CAST(TotalMinutes AS VARCHAR(3)) + '')'' AS PointsAndMinutes
			FROM PlayerGameweekPoints pgp
		) src
		PIVOT
		(
			MIN(PointsAndMinutes)
			FOR GameweekKey IN (' + @colHeaders + ')
		) piv
	)
	SELECT piv.*, ptp.TotalMinutes, ptp.TotalPoints
	FROM PlayerGameweekPivot piv
	INNER JOIN PlayerTotalPoints ptp
	ON piv.PlayerKey = ptp.PlayerKey
	ORDER BY PlayerPositionKey, TotalPoints DESC, TotalMinutes DESC;';

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT, @TeamKey INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @TeamKey = @TeamKey;

END