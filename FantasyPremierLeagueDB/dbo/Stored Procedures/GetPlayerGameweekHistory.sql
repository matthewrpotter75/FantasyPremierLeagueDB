CREATE PROCEDURE dbo.GetPlayerGameweekHistory
(
	@PlayerId INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL
)
AS
BEGIN

	SELECT FirstName + ' ' + SecondName AS PlayerName
	FROM dbo.DimPlayer
	WHERE PlayerId = @PlayerId
	OR (FirstName = @FirstName AND SecondName = @SecondName);

	SELECT fph.SeasonId, fph.GameweekFixtureId, fph.GameweekId, dht.TeamShortName As HomeTeam, dat.TeamShortName AS AwayTeam, dgf.HomeTeamId, dgf.AwayTeamId, fph.OpponentTeamId, fph.[Minutes], fph.TotalPoints
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.DimGameweekFixture dgf
	ON fph.GameweekFixtureId = dgf.GameweekFixtureId
	INNER JOIN dbo.DimPlayer dp
	ON fph.PlayerId = dp.PlayerId
	INNER JOIN dbo.DimTeam dht
	ON dgf.HomeTeamId = dht.TeamId
	INNER JOIN dbo.DimTeam dat
	ON dgf.AwayTeamId = dat.TeamId
	WHERE fph.PlayerId = @PlayerId
	OR (dp.FirstName = @FirstName AND dp.SecondName = @SecondName)
	ORDER BY fph.GameweekFixtureId;

END