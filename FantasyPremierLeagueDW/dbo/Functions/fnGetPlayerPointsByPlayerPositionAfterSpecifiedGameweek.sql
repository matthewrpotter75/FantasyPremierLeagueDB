CREATE FUNCTION dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek
(
	@PlayerPositionKey INT,
	@SeasonKey INT,
	@StartGameweekKey INT = 1,
	@MinutesCutoff INT = 0,
	@MaxCost INT = 1000	
)
RETURNS TABLE
AS
RETURN
(
	WITH PlayerPointsFullSeason AS
	(
		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort,
		SUM(ph.TotalPoints) AS TotalPointsFullSeason,
		COUNT(ph.TotalPoints) AS CountGamesFullSeason,
		AVG(CAST(ph.TotalPoints AS DECIMAL(6,2))) AS AvgPointsPerGameFullSeason
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE pp.PlayerPositionKey = @PlayerPositionKey
		AND ph.SeasonKey = @SeasonKey
		AND ph.[Minutes] > @MinutesCutoff
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort
	),
	PlayerPointsAfterGameweek AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS TotalPointsAfterGameweek,
		COUNT(ph.TotalPoints) AS CountGamesAfterGameweek,
		AVG(CAST(ph.TotalPoints AS DECIMAL(6,2))) AS AvgPointsPerGameAfterGameweek
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE pp.PlayerPositionKey = @PlayerPositionKey
		AND ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey >= @StartGameweekKey
		AND ph.[Minutes] > @MinutesCutoff
		GROUP BY ph.PlayerKey, p.PlayerName
	)
	SELECT ppfs.PlayerKey,
	ppfs.PlayerName,
	ppfs.PlayerPositionShort AS PlayerPosition,
	t.TeamName,
	pcs.Cost,
	ppag.TotalPointsAfterGameweek,
	ppfs.TotalPointsFullSeason,	
	--ppag.CountGamesAfterGameweek,
	--ppfs.CountGamesFullSeason,
	CAST(ppag.AvgPointsPerGameAfterGameweek AS DECIMAL(5,2)) AS AvgPointsPerGameAfterGameweek,
	CAST(ppfs.AvgPointsPerGameFullSeason AS DECIMAL(5,2)) AS AvgPointsPerGameFullSeason,
	CAST((ppag.AvgPointsPerGameAfterGameweek - ppfs.AvgPointsPerGameFullSeason) AS DECIMAL(5,2)) AS PointsAboveSeasonAvg,
	CASE
		WHEN ppfs.TotalPointsFullSeason > 0 THEN
			CAST(((CAST(ppag.TotalPointsAfterGameweek AS DECIMAL(8,4))/CAST(ppfs.TotalPointsFullSeason AS DECIMAL(8,4))) * 100) AS DECIMAL(6,2))
		ELSE 0
	END
	AS PercentagePointInGameweekRange
	FROM PlayerPointsFullSeason ppfs
	INNER JOIN PlayerPointsAfterGameweek ppag
	ON ppfs.PlayerKey = ppag.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON ppfs.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON ppfs.PlayerKey = pcs.PlayerKey
	WHERE pcs.Cost <= @MaxCost
);