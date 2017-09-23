CREATE FUNCTION dbo.fnGetPlayerHistoryRankedByPoints
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Calculate points per game for each player by difficulty of opposition for previous number gameweeks
	SELECT ph.PlayerKey,
	ph.PlayerHistoryKey,
	ph.SeasonKey,
	ph.GameweekKey,
	ROW_NUMBER() OVER (PARTITION BY ph.PlayerKey ORDER BY ph.TotalPoints DESC) AS PointsGameweekRank,
	ph.TotalPoints,
	ph.[Minutes],
	ph.WasHome,
	ph.OpponentTeamKey,
	pa.PlayerPositionKey
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayerAttribute pa
	ON ph.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	WHERE [Minutes] > @MinutesLimit
	AND pa.PlayerPositionKey = @PlayerPositionKey
);