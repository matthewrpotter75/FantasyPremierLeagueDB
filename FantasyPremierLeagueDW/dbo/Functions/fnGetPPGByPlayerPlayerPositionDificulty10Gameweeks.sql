CREATE FUNCTION dbo.fnGetPPGByPlayerPlayerPositionDificulty10Gameweeks
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Calculate points per game for each player by difficulty of opposition for previous 10 gameweeks
	SELECT ph.PlayerKey,
	ph.PlayerPositionKey,
	d.Difficulty AS OpponentDifficulty,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.PlayerKey) AS Games,
	SUM(ph.[Minutes]) AS PlayerMinutes,
	--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG10
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG10
	FROM dbo.fnGetPlayerHistoryRankedByGameweek(@SeasonKey,@PlayerPositionKey,@MinutesLimit) ph
	INNER JOIN dbo.DimPlayer p
	ON ph.PlayerKey = p.PlayerKey 
	INNER JOIN dbo.DimTeamDifficulty d
	ON ph.OpponentTeamKey = d.TeamKey
	AND ph.WasHome = d.IsOpponentHome
	AND ph.SeasonKey = d.SeasonKey
	WHERE ph.[Minutes] > @MinutesLimit
	--AND ph.GameweekKey BETWEEN (@GameweekStart - 10) AND @GameweekStart
	AND ph.GameweekInc BETWEEN 1 AND 10
	GROUP BY ph.PlayerKey, ph.PlayerPositionKey, d.Difficulty
);