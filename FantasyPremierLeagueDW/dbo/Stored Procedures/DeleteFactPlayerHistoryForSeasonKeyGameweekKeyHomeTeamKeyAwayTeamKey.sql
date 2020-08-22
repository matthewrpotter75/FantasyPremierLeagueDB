CREATE PROCEDURE dbo.DeleteFactPlayerHistoryForSeasonKeyGameweekKeyHomeTeamKeyAwayTeamKey
(
	@SeasonKey INT,
	@GameweekKey INT,
	@TeamKey INT,
	@AwayTeamKey INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @Debug = 1
	BEGIN

		SELECT p.PlayerName, fph.*, fgf.HomeTeamKey, fgf.AwayTeamKey
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.FactGameweekFixture fgf
		ON fph.GameweekFixtureKey = fgf.GameweekFixtureKey
		INNER JOIN dbo.DimPlayer p
		ON fph.PlayerKey = p.PlayerKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey = @GameweekKey
		AND fgf.HomeTeamKey = @TeamKey
		AND fgf.AwayTeamKey = @AwayTeamKey
		ORDER BY fph.WasHome DESC;

	END
	ELSE
	BEGIN

		DELETE fph
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.FactGameweekFixture fgf
		ON fph.GameweekFixtureKey = fgf.GameweekFixtureKey
		INNER JOIN dbo.DimPlayer p
		ON fph.PlayerKey = p.PlayerKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey = @GameweekKey
		AND fgf.HomeTeamKey = @TeamKey
		AND fgf.AwayTeamKey = @AwayTeamKey;

	END

END
GO