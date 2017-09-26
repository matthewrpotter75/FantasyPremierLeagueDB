CREATE PROCEDURE dbo.GetPlayerGameweekHistoryStatsByDifficultyWasHome
(
	@PlayerKey INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL,
	@MinutesLimit INT = 30
)
AS
BEGIN

	IF @PlayerKey IS NULL
	BEGIN

		SELECT @PlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE FirstName = @FirstName AND SecondName = @SecondName;

	END

	SELECT PlayerName
	FROM dbo.DimPlayer
	WHERE PlayerKey = @PlayerKey;

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
	INNER JOIN dbo.DimTeam dht
	ON dgf.HomeTeamKey = dht.TeamKey
	INNER JOIN dbo.DimTeam dat
	ON dgf.AwayTeamKey = dat.TeamKey
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON fph.OpponentTeamKey = dtd.TeamKey
	AND fph.WasHome = dtd.IsOpponentHome
	AND fph.SeasonKey = dtd.SeasonKey
	WHERE fph.PlayerKey = @PlayerKey
	AND fph.[Minutes] >= @MinutesLimit
	GROUP BY dtd.Difficulty, fph.WasHome
	ORDER BY dtd.Difficulty, fph.WasHome

END