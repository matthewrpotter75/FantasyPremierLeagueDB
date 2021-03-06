CREATE PROCEDURE dbo.GetBlankedFixturesInDimTeamGameweekFixtureCounts
(
	@SeasonKey INT = NULL
)
AS
BEGIN

	SELECT t.TeamShortName AS Team, COUNT(1) AS GameCount
	FROM dbo.DimTeamGameweekFixture tgf
	INNER JOIN dbo.DimTeam t
	ON tgf.TeamKey = t.TeamKey
	INNER JOIN dbo.DimTeam ot
	ON tgf.OpponentTeamKey = ot.TeamKey
	WHERE tgf.GameweekKey = -1
	AND 
	(
		tgf.SeasonKey = @SeasonKey
		OR
		@SeasonKey IS NULL
	)
	GROUP BY t.TeamShortName
	ORDER BY GameCount DESC, Team;

END