CREATE FUNCTION dbo.fnGetOverallTeamPPG
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Create temp table with overall points per game per team, opponent difficulty, and home/away
	SELECT pa.TeamKey, 
	pa.PlayerPositionKey,
	otd.Difficulty AS OppositionTeamDifficulty,
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
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeamDifficulty otd
	ON ph.OpponentTeamKey = otd.TeamKey
	AND ph.SeasonKey = otd.SeasonKey
	WHERE ph.[Minutes] > @MinutesLimit
	AND pa.PlayerPositionKey = @PlayerPositionKey
	GROUP BY pa.TeamKey, ph.WasHome, pa.PlayerPositionKey, otd.Difficulty
);