CREATE FUNCTION dbo.fnGetFixtures
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@GameweekStart INT,
	@GameweekEnd INT,
	@SeasonEnd INT
)
RETURNS TABLE
AS
RETURN
(
	--Get list of fixtures in the gameweeks to be analysed
	SELECT DISTINCT f.GameweekFixtureKey, 
	f.SeasonKey, 
	f.GameweekKey, 
	htd.Difficulty AS TeamDifficulty, 
	otd.Difficulty AS OpponentDifficulty, 
	f.TeamKey, 
	f.OpponentTeamKey, 
	f.IsHome, 
	CAST(gf.KickoffTime AS DATE) AS KickoffDate
	FROM dbo.DimTeamGameweekFixture f
	INNER JOIN dbo.FactGameweekFixture gf
	ON f.GameweekFixtureKey = gf.GameweekFixtureKey
	INNER JOIN dbo.DimTeamDifficulty htd
	ON f.TeamKey = htd.TeamKey
	AND f.IsHome = htd.IsOpponentHome
	AND htd.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeamDifficulty otd
	ON f.OpponentTeamKey = otd.TeamKey
	AND f.IsHome = otd.IsOpponentHome
	AND otd.SeasonKey = @SeasonKey
	WHERE (f.GameweekKey >= @GameweekStart AND f.SeasonKey = @SeasonKey)
	OR (f.GameweekKey <= @GameweekEnd AND f.SeasonKey = @SeasonEnd)
);