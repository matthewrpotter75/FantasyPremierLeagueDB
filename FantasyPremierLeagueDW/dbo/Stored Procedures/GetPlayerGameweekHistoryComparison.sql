CREATE PROCEDURE dbo.GetPlayerGameweekHistoryComparison
(
	@PlayerKey INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL,
	@ComparisonPlayerKey INT = NULL,
	@ComparisonFirstName VARCHAR(50) = NULL,
	@ComparisonSecondName VARCHAR(50) = NULL,
	@SeasonKey INT = NULL
)
--Examples
--EXEC dbo.GetPlayerGameweekHistoryComparison @PlayerKey = 212, @ComparisonPlayerKey = 2;
--EXEC dbo.GetPlayerGameweekHistoryComparison @FirstName = 'Romelu', @SecondName = 'Lukaku', @ComparisonFirstName = 'Aaron', @ComparisonSecondName = 'Lennon';
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MaxSeasonKey INT;

	IF @PlayerKey IS NULL
	BEGIN

		SELECT @PlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE FirstName = @FirstName AND SecondName = @SecondName;

	END

	IF @ComparisonPlayerKey IS NULL
	BEGIN

		SELECT @ComparisonPlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE FirstName = @ComparisonFirstName AND SecondName = @ComparisonSecondName;

	END

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @MaxSeasonKey = SeasonKey
		FROM dbo.FactPlayerHistory
		WHERE PlayerKey IN (@PlayerKey, @ComparisonPlayerKey)
	END

	;WITH player AS
	(
		SELECT PlayerName
		FROM dbo.DimPlayer
		WHERE PlayerKey = @PlayerKey
	),
	comparisonPlayer AS
	(
		SELECT PlayerName AS ComparisonPlayerName
		FROM dbo.DimPlayer
		WHERE PlayerKey = @ComparisonPlayerKey
	)
	SELECT PlayerName, ComparisonPlayerName
	FROM player, comparisonPlayer;

	;WITH playerStats AS
	(
		SELECT fph.SeasonKey, 
		fph.GameweekFixtureKey, 
		fph.GameweekKey, 
		dht.TeamShortName As HomeTeam, 
		dat.TeamShortName AS AwayTeam, 
		fph.[Minutes], 
		fph.TotalPoints, 
		dtd.Difficulty, 
		ROW_NUMBER() OVER(PARTITION BY fph.SeasonKey, fph.GameweekKey ORDER BY dgf.KickoffTime ASC) AS RowNum
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.FactGameweekFixture dgf
		ON fph.GameweekFixtureKey = dgf.GameweekFixtureKey
		AND dgf.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
		INNER JOIN dbo.DimPlayer dp
		ON fph.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimTeam dht
		ON dgf.HomeTeamKey = dht.TeamKey
		INNER JOIN dbo.DimTeam dat
		ON dgf.AwayTeamKey = dat.TeamKey
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON fph.OpponentTeamKey = dtd.TeamKey
		AND fph.SeasonKey = dtd.SeasonKey
		AND fph.WasHome = dtd.IsOpponentHome
		AND dtd.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
		WHERE fph.PlayerKey = @PlayerKey
		AND fph.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
	),
	comparisonPlayerStats AS
	(
		SELECT fph.SeasonKey, 
		fph.GameweekFixtureKey, 
		fph.GameweekKey, 
		dht.TeamShortName AS HomeTeam, 
		dat.TeamShortName AS AwayTeam, 
		fph.[Minutes], 
		fph.TotalPoints, 
		dtd.Difficulty, 
		ROW_NUMBER() OVER(PARTITION BY fph.SeasonKey, fph.GameweekKey ORDER BY dgf.KickoffTime ASC) AS RowNum
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.FactGameweekFixture dgf
		ON fph.GameweekFixtureKey = dgf.GameweekFixtureKey
		AND dgf.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
		INNER JOIN dbo.DimPlayer dp
		ON fph.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimTeam dht
		ON dgf.HomeTeamKey = dht.TeamKey
		INNER JOIN dbo.DimTeam dat
		ON dgf.AwayTeamKey = dat.TeamKey
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON fph.OpponentTeamKey = dtd.TeamKey
		AND fph.SeasonKey = dtd.SeasonKey
		AND fph.WasHome = dtd.IsOpponentHome
		AND dtd.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
		WHERE fph.PlayerKey = @ComparisonPlayerKey
		AND fph.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
	)
	SELECT ISNULL(playerStats.SeasonKey, comparisonPlayerStats.SeasonKey) AS SeasonKey,
	ISNULL(playerStats.GameweekKey, comparisonPlayerStats.GameweekKey) AS GameweekKey,
	ISNULL(playerStats.HomeTeam,'') AS HomeTeam, 
	ISNULL(playerStats.AwayTeam,'') AS AwayTeam,
	playerStats.Difficulty,
	playerStats.[Minutes], 
	playerStats.TotalPoints,
	comparisonPlayerStats.[Minutes] AS ComparisonMinutes,
	comparisonPlayerStats.TotalPoints AS ComparisonTotalPoints,
	ISNULL(comparisonPlayerStats.HomeTeam,'') AS ComparisonPlayerHomeTeam, 
	ISNULL(comparisonPlayerStats.AwayTeam,'') AS ComparisonPlayerAwayTeam
	FROM playerStats
	FULL OUTER JOIN comparisonPlayerStats
	ON playerStats.SeasonKey = comparisonPlayerStats.SeasonKey
	AND playerStats.GameweekKey = comparisonPlayerStats.GameweekKey
	AND playerStats.RowNum = comparisonPlayerStats.RowNum
	ORDER BY ISNULL(playerStats.SeasonKey, comparisonPlayerStats.SeasonKey), ISNULL(playerStats.GameweekKey, comparisonPlayerStats.GameweekKey);

END