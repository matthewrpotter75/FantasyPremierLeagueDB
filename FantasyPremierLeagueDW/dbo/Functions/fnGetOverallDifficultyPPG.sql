CREATE FUNCTION dbo.fnGetOverallDifficultyPPG
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Create temp table with overall points per game per team difficulty and opponent difficulty
	SELECT htd.Difficulty AS TeamDifficulty, 
	otd.Difficulty AS OppositionTeamDifficulty,
	pa.PlayerPositionKey,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.PlayerKey) AS Games,
	SUM(ph.[Minutes]) AS PlayerMinutes,
	--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayerAttribute pa
	ON ph.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeamDifficulty htd
	ON pa.TeamKey = htd.TeamKey
	AND ph.SeasonKey = htd.SeasonKey
	INNER JOIN dbo.DimTeamDifficulty otd
	ON ph.OpponentTeamKey = otd.TeamKey
	AND ph.SeasonKey = otd.SeasonKey
	WHERE ph.[Minutes] > @MinutesLimit
	AND pa.PlayerPositionKey = @PlayerPositionKey
	GROUP BY htd.Difficulty, otd.Difficulty, pa.PlayerPositionKey
);