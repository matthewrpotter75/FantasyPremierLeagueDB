CREATE PROCEDURE dbo.GetPlayerGameweekHistory
(
	@PlayerId INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL
)
AS
BEGIN

	IF @PlayerId IS NULL
	BEGIN

		SELECT @PlayerId = [PlayerKey]
		FROM dbo.DimPlayer
		WHERE FirstName = @FirstName AND SecondName = @SecondName;

	END

	SELECT PlayerName
	FROM dbo.DimPlayer
	WHERE [PlayerKey] = @PlayerId;

	SELECT fph.[SeasonKey], 
	fph.[GameweekFixtureKey], 
	fph.[GameweekKey], 
	dht.TeamShortName As HomeTeam, 
	dat.TeamShortName AS AwayTeam, 
	fph.WasHome,
	fph.[OpponentTeamKey], 
	fph.[Minutes], 
	fph.TotalPoints
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.FactGameweekFixture dgf
	ON fph.[GameweekFixtureKey] = dgf.[GameweekFixtureKey]
	INNER JOIN dbo.DimPlayer dp
	ON fph.[PlayerKey] = dp.[PlayerKey]
	INNER JOIN dbo.DimTeam dht
	ON dgf.[HomeTeamKey] = dht.[TeamKey]
	INNER JOIN dbo.DimTeam dat
	ON dgf.[AwayTeamKey] = dat.[TeamKey]
	WHERE fph.[PlayerKey] = @PlayerId
	ORDER BY fph.[GameweekFixtureKey];

END