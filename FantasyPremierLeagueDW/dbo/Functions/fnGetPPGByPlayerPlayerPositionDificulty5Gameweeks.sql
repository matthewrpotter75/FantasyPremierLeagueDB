CREATE FUNCTION dbo.fnGetPPGByPlayerPlayerPositionDificulty5Gameweeks
(
	@SeasonKey INT,
	@GameweekKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Calculate points per game for each player by difficulty of opposition for previous 5 gameweeks
	WITH fnGetPlayerHistoryRankedByGameweek AS
	(
		SELECT ph.PlayerKey,
		ph.SeasonKey,
		ph.GameweekKey,
		ROW_NUMBER() OVER (PARTITION BY ph.PlayerKey, d.Difficulty ORDER BY ph.SeasonKey DESC, ph.GameweekKey DESC) AS GameweekInc,
		ph.TotalPoints,
		ph.[Minutes],
		ph.WasHome,
		ph.OpponentTeamKey,
		pa.PlayerPositionKey,
		d.Difficulty
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimTeamDifficulty d
		ON ph.OpponentTeamKey = d.TeamKey
		AND ph.WasHome = d.IsOpponentHome
		AND ph.SeasonKey = d.SeasonKey
		WHERE [Minutes] > @MinutesLimit
		AND 
		(
			(ph.SeasonKey = @SeasonKey AND ph.GameweekKey < @GameweekKey)
			OR
			ph.SeasonKey < @SeasonKey
		)
	)
	SELECT ph.PlayerKey,
	ph.PlayerPositionKey,
	ph.Difficulty AS OpponentDifficulty,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.PlayerKey) AS Games,
	SUM(ph.[Minutes]) AS PlayerMinutes,
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG5
	FROM fnGetPlayerHistoryRankedByGameweek ph
	WHERE ph.GameweekInc <= 5
	GROUP BY ph.PlayerKey, ph.PlayerPositionKey, ph.Difficulty
);