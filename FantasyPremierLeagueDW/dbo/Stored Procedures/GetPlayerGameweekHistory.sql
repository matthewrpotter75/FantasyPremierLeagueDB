CREATE PROCEDURE dbo.GetPlayerGameweekHistory
(
	@PlayerKey INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL,
	@SeasonKey INT = NULL
)
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

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @MaxSeasonKey = SeasonKey
		FROM dbo.FactPlayerHistory
		WHERE PlayerKey = @PlayerKey
	END

	SELECT PlayerKey, PlayerName
	FROM dbo.DimPlayer
	WHERE PlayerKey = @PlayerKey;

	SELECT fph.SeasonKey, 
	fph.GameweekFixtureKey, 
	fph.GameweekKey, 
	dht.TeamShortName As HomeTeam, 
	dat.TeamShortName AS AwayTeam, 
	fph.WasHome,
	fph.OpponentTeamKey, 
	dtd.Difficulty,
	fph.[Minutes], 
	fph.TotalPoints
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
	AND fph.WasHome = dtd.IsOpponentHome
	AND fph.SeasonKey = dtd.SeasonKey
	AND dtd.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
	WHERE fph.PlayerKey = @PlayerKey
	AND fph.SeasonKey = ISNULL(@SeasonKey, @MaxSeasonKey)
	ORDER BY fph.SeasonKey, fph.GameweekKey;

END