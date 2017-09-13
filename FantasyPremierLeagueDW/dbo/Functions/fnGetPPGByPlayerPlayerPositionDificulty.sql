CREATE FUNCTION dbo.fnGetPPGByPlayerPlayerPositionDificulty
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Calculate points per game for each player by difficulty of opposition
	SELECT p.PlayerKey,
	pa.PlayerPositionKey,
	d.Difficulty AS OpponentDifficulty,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.PlayerKey) AS Games,
	SUM(ph.[Minutes]) AS PlayerMinutes,
	--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer p
	ON ph.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND ph.SeasonKey = pa.SeasonKey
	INNER JOIN dbo.DimTeamDifficulty d
	ON ph.OpponentTeamKey = d.TeamKey
	AND d.SeasonKey = @SeasonKey
	AND ph.WasHome = d.IsOpponentHome
	AND ph.SeasonKey = pa.SeasonKey
	WHERE ph.[Minutes] > @MinutesLimit
	AND pa.PlayerPositionKey = @PlayerPositionKey
	AND NOT EXISTS
	(
		SELECT 1
		FROM dbo.fnGetPlayerHistoryRankedByPoints(@SeasonKey,@PlayerPositionKey,@MinutesLimit) phr
		WHERE phr.PlayerHistoryKey = ph.PlayerHistoryKey
		AND phr.PointsGameweekRank = 1
	)
	GROUP BY p.PlayerKey, pa.PlayerPositionKey, d.Difficulty
);