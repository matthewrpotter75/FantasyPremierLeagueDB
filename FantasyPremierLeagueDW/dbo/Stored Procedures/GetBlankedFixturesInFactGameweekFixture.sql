CREATE PROCEDURE dbo.GetBlankedFixturesInFactGameweekFixture
(
	@SeasonKey INT = NULL
)
AS
BEGIN

	SELECT ht.TeamShortName AS HomeTeam, awt.TeamShortName AS AwayTeam, fgf.*
	FROM dbo.FactGameweekFixture fgf
	INNER JOIN dbo.DimTeam ht
	ON fgf.HomeTeamKey = ht.TeamKey
	INNER JOIN dbo.DimTeam awt
	ON fgf.AwayTeamKey = awt.TeamKey
	WHERE fgf.GameweekKey = -1
	AND 
	(
		fgf.SeasonKey = @SeasonKey
		OR
		@SeasonKey IS NULL
	)
	ORDER BY HomeTeam, AwayTeam;

END