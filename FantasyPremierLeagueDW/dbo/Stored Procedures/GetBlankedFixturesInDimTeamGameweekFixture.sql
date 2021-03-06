CREATE PROCEDURE dbo.GetBlankedFixturesInDimTeamGameweekFixture
(
	@SeasonKey INT = NULL
)
AS
BEGIN

	SELECT t.TeamShortName AS Team, ot.TeamShortName AS OpponentTeam, tgf.*
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
	ORDER BY Team, OpponentTeam;

END