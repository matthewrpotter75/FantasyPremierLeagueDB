CREATE PROCEDURE dbo.GetGameweekPlayerHistoryForSeason
(
	--DECLARE
	@PlayerId INT = 40,
	@SeasonId INT = 11
)
AS
BEGIN

	SELECT fph.GameweekId, fph.WasHome, dtd.Difficulty, fph.TotalPoints
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON fph.PlayerId = dpa.PlayerId
	AND fph.SeasonId = dpa.SeasonId
	INNER JOIN dbo.DimTeamSeason dts
	ON dpa.TeamId = dts.TeamId
	AND fph.SeasonId = dts.SeasonId
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON dts.TeamId = dtd.TeamId
	AND fph.SeasonId = dtd.SeasonId
	AND fph.WasHome = dtd.IsHome
	WHERE fph.PlayerId = @PlayerId
	AND fph.SeasonId = @SeasonId
	ORDER BY fph.GameweekId;

END