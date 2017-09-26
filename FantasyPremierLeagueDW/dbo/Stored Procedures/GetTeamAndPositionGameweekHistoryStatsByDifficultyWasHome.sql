CREATE PROCEDURE dbo.GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHome
(
	@TeamKey INT = NULL,
	@TeamShortName VARCHAR(3) = NULL,
	@PlayerPositionKey VARCHAR(50) = NULL,
	@SeasonKey INT = 12,
	@MinutesLimit INT = 30
)
AS
BEGIN

	IF @TeamKey IS NULL
	BEGIN

		SELECT @TeamKey = TeamKey
		FROM dbo.DimTeam
		WHERE TeamShortName = @TeamShortName;

	END

	SELECT PlayerPositionShort AS PlayerPosition
	FROM dbo.DimPlayerPosition
	WHERE PlayerPositionKey = @PlayerPositionKey;

	SELECT TeamName, TeamShortName
	FROM dbo.DimTeam
	WHERE TeamKey = @TeamKey;

	SELECT 
	fph.WasHome,
	dtd.Difficulty AS OpponentDifficulty,
	COUNT(fph.PlayerHistoryKey) AS TotalGames,
	SUM(fph.[Minutes]) AS TotalMinutes, 
	SUM(fph.TotalPoints) AS TotalPoints,
	(SUM(fph.TotalPoints) * 1.00)/COUNT(fph.PlayerHistoryKey) AS PointPerGame
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.FactGameweekFixture dgf
	ON fph.GameweekFixtureKey = dgf.GameweekFixtureKey
	INNER JOIN dbo.DimPlayer dp
	ON fph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON dp.PlayerKey = dpa.PlayerKey
	AND dpa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON fph.OpponentTeamKey = dtd.TeamKey
	AND fph.WasHome = dtd.IsOpponentHome
	AND fph.SeasonKey = dtd.SeasonKey
	WHERE dpa.TeamKey = @TeamKey
	AND dpa.PlayerPositionKey = @PlayerPositionKey
	AND fph.[Minutes] > @MinutesLimit
	GROUP BY dtd.Difficulty, fph.WasHome
	ORDER BY dtd.Difficulty, fph.WasHome

END