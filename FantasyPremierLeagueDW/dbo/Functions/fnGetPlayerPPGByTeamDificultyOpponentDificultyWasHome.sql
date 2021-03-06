CREATE FUNCTION dbo.fnGetPlayerPPGByTeamDificultyOpponentDificultyWasHome
(
	@SeasonKey INT,
	@PlayerKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Calculate points per game for each player by difficulty of opposition
	SELECT p.PlayerKey,
	pa.PlayerPositionKey,
	td.Difficulty AS TeamDifficulty,
	od.Difficulty AS OpponentDifficulty,
	ph.WasHome,
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
	INNER JOIN dbo.DimTeamDifficulty td
	ON pa.TeamKey = td.TeamKey
	AND td.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeamDifficulty od
	ON ph.OpponentTeamKey = od.TeamKey
	AND od.SeasonKey = @SeasonKey
	AND ph.WasHome = od.IsOpponentHome
	AND ph.SeasonKey = pa.SeasonKey
	WHERE p.PlayerKey = @PlayerKey
	AND ph.[Minutes] > @MinutesLimit
	GROUP BY p.PlayerKey, pa.PlayerPositionKey, td.Difficulty, od.Difficulty, ph.WasHome
);