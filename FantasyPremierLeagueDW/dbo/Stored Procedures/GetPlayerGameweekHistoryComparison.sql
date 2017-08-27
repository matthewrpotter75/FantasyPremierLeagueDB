CREATE PROCEDURE dbo.GetPlayerGameweekHistoryComparison
(
	@PlayerId INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL,
	@ComparisonPlayerId INT = NULL,
	@ComparisonFirstName VARCHAR(50) = NULL,
	@ComparisonSecondName VARCHAR(50) = NULL
)
--Examples
--EXEC dbo.GetPlayerGameweekHistoryComparison @playerId = 212, @comparisonPlayerId = 2;
--EXEC dbo.GetPlayerGameweekHistoryComparison @FirstName = 'Romelu', @SecondName = 'Lukaku', @comparisonFirstName = 'Aaron', @comparisonSecondName = 'Lennon';
AS
BEGIN

	IF @PlayerId IS NULL
	BEGIN

		SELECT @PlayerId = [PlayerKey]
		FROM dbo.DimPlayer
		WHERE FirstName = @FirstName AND SecondName = @SecondName;

	END

	IF @ComparisonPlayerId IS NULL
	BEGIN

		SELECT @ComparisonPlayerId = [PlayerKey]
		FROM dbo.DimPlayer
		WHERE FirstName = @ComparisonFirstName AND SecondName = @ComparisonSecondName;

	END

	;WITH player AS
	(
		SELECT PlayerName
		FROM dbo.DimPlayer
		WHERE [PlayerKey] = @PlayerId
	),
	comparisonPlayer AS
	(
		SELECT PlayerName AS ComparisonPlayerName
		FROM dbo.DimPlayer
		WHERE [PlayerKey] = @ComparisonPlayerId
	)
	SELECT PlayerName, ComparisonPlayerName
	FROM player, comparisonPlayer;

	;WITH playerStats AS
	(
		SELECT fph.[SeasonKey], 
		fph.[GameweekFixtureKey], 
		fph.[GameweekKey], 
		dht.TeamShortName As HomeTeam, 
		dat.TeamShortName AS AwayTeam, 
		fph.[Minutes], 
		fph.TotalPoints, 
		dtd.Difficulty, 
		ROW_NUMBER() OVER(PARTITION BY fph.[SeasonKey], fph.[GameweekKey] ORDER BY dgf.KickoffTime ASC) AS RowNum
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.FactGameweekFixture dgf
		ON fph.[GameweekFixtureKey] = dgf.[GameweekFixtureKey]
		INNER JOIN dbo.DimPlayer dp
		ON fph.[PlayerKey] = dp.[PlayerKey]
		INNER JOIN dbo.DimTeam dht
		ON dgf.[HomeTeamKey] = dht.[TeamKey]
		INNER JOIN dbo.DimTeam dat
		ON dgf.[AwayTeamKey] = dat.[TeamKey]
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON fph.[OpponentTeamKey] = dtd.TeamKey
		AND fph.[SeasonKey] = dtd.SeasonKey
		AND fph.WasHome = dtd.IsOpponentHome
		WHERE fph.[PlayerKey] = @PlayerId
	),
	comparisonPlayerStats AS
	(
		SELECT fph.[SeasonKey], 
		fph.[GameweekFixtureKey], 
		fph.[GameweekKey], 
		dht.TeamShortName AS HomeTeam, 
		dat.TeamShortName AS AwayTeam, 
		fph.[Minutes], 
		fph.TotalPoints, 
		dtd.Difficulty, 
		ROW_NUMBER() OVER(PARTITION BY fph.[SeasonKey], fph.[GameweekKey] ORDER BY dgf.KickoffTime ASC) AS RowNum
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.FactGameweekFixture dgf
		ON fph.[GameweekFixtureKey] = dgf.[GameweekFixtureKey]
		INNER JOIN dbo.DimPlayer dp
		ON fph.[PlayerKey] = dp.[PlayerKey]
		INNER JOIN dbo.DimTeam dht
		ON dgf.[HomeTeamKey] = dht.[TeamKey]
		INNER JOIN dbo.DimTeam dat
		ON dgf.[AwayTeamKey] = dat.[TeamKey]
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON fph.[OpponentTeamKey] = dtd.TeamKey
		AND fph.[SeasonKey] = dtd.SeasonKey
		AND fph.WasHome = dtd.IsOpponentHome
		WHERE fph.[PlayerKey] = @ComparisonPlayerId
	)
	SELECT ISNULL(playerStats.[SeasonKey], comparisonPlayerStats.[SeasonKey]) AS SeasonId,
	ISNULL(playerStats.[GameweekKey], comparisonPlayerStats.[GameweekKey]) AS GameweekId,
	ISNULL(playerStats.HomeTeam,'') AS HomeTeam, 
	ISNULL(playerStats.AwayTeam,'') AS AwayTeam, 
	playerStats.[Minutes], 
	playerStats.Difficulty,
	playerStats.TotalPoints,
	ISNULL(comparisonPlayerStats.HomeTeam,'') AS ComparisonPlayerHomeTeam, 
	ISNULL(comparisonPlayerStats.AwayTeam,'') AS ComparisonPlayerAwayTeam, 
	comparisonPlayerStats.[Minutes],
	comparisonPlayerStats.Difficulty,
	comparisonPlayerStats.TotalPoints
	FROM playerStats
	FULL OUTER JOIN comparisonPlayerStats
	ON playerStats.[SeasonKey] = comparisonPlayerStats.[SeasonKey]
	AND playerStats.[GameweekKey] = comparisonPlayerStats.[GameweekKey]
	AND playerStats.RowNum = comparisonPlayerStats.RowNum
	ORDER BY ISNULL(playerStats.[SeasonKey], comparisonPlayerStats.[SeasonKey]), ISNULL(playerStats.[GameweekKey], comparisonPlayerStats.[GameweekKey]);

END