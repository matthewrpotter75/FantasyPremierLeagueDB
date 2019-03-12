CREATE FUNCTION dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks
(
	@SeasonKey INT,
	@GameweekKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT,
	@Gameweeks INT
)
RETURNS TABLE    
AS    
RETURN    
(    
	--Calculate points per game for each player by difficulty of opposition for previous number of gameweeks specified    
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
		d.Difficulty,
		gf.KickoffTime
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND ph.SeasonKey = pa.SeasonKey
		INNER JOIN dbo.DimTeamDifficulty d
		ON ph.OpponentTeamKey = d.TeamKey
		AND ph.WasHome = d.IsOpponentHome
		AND ph.SeasonKey = d.SeasonKey
		INNER JOIN dbo.FactGameweekFixture gf
		ON ph.GameweekFixtureKey = gf.GameweekFixtureKey
		WHERE pa.PlayerPositionKey = @PlayerPositionKey
		AND [Minutes] > @MinutesLimit
		AND
		(
			(ph.SeasonKey = @SeasonKey AND ph.GameweekKey <= @GameweekKey)
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
	MIN(KickoffTime) AS MinGameweekFixtureDatetime,
	MAX(KickoffTime) AS MaxGameweekFixtureDatetime,
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG
	FROM fnGetPlayerHistoryRankedByGameweek ph
	WHERE ph.GameweekInc <= @Gameweeks
	GROUP BY ph.PlayerKey, ph.PlayerPositionKey, ph.Difficulty
);