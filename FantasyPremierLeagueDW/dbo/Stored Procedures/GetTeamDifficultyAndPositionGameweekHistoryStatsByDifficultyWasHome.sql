CREATE PROCEDURE dbo.GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHome
(
	@TeamDifficulty INT = NULL,
	@PlayerPositionKey VARCHAR(50) = NULL,
	@TeamShortName VARCHAR(3) = NULL,
	@SeasonKey INT = 12,
	@MinutesLimit INT = 30
)
AS
BEGIN

	SELECT PlayerPositionShort AS PlayerPosition
	FROM dbo.DimPlayerPosition
	WHERE PlayerPositionKey = @PlayerPositionKey;

	IF @TeamDifficulty IS NULL AND @TeamShortName IS NOT NULL
	BEGIN

		SELECT @TeamDifficulty = dtd.Difficulty
		FROM dbo.DimTeam dt
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON dt.TeamKey = dtd.TeamKey
		AND dtd.SeasonKey = @SeasonKey
		WHERE dt.TeamShortName = @TeamShortName;

		SELECT @TeamShortName AS TeamShortName, @TeamDifficulty AS TeamDifficulty;

	END
	ELSE
	BEGIN

		SELECT @TeamDifficulty AS TeamDifficulty;

	END

	SELECT dtd.Difficulty AS TeamDifficulty,
	fph.WasHome,
	odtd.Difficulty AS OpponentDifficulty,
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
	ON dpa.TeamKey = dtd.TeamKey
	AND fph.WasHome = dtd.IsOpponentHome
	AND fph.SeasonKey = dtd.SeasonKey
	INNER JOIN dbo.DimTeamDifficulty odtd
	ON fph.OpponentTeamKey = odtd.TeamKey
	AND fph.WasHome = odtd.IsOpponentHome
	AND fph.SeasonKey = odtd.SeasonKey
	WHERE dtd.Difficulty = @TeamDifficulty
	AND dpa.PlayerPositionKey = @PlayerPositionKey
	AND fph.[Minutes] > @MinutesLimit
	GROUP BY dtd.Difficulty, odtd.Difficulty, fph.WasHome
	ORDER BY dtd.Difficulty, odtd.Difficulty, fph.WasHome

END