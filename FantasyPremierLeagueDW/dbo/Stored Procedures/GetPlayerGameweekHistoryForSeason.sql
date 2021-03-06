CREATE PROCEDURE dbo.GetPlayerGameweekHistoryForSeason
(
	--DECLARE
	@PlayerKey INT = 40,
	@SeasonKey INT = 11
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT fph.GameweekKey, fph.WasHome, dtd.Difficulty, fph.TotalPoints
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON fph.PlayerKey = dpa.PlayerKey
	AND fph.SeasonKey = dpa.SeasonKey
	INNER JOIN dbo.DimTeamSeason dts
	ON dpa.TeamKey = dts.TeamKey
	AND fph.SeasonKey = dts.SeasonKey
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON dts.TeamKey = dtd.TeamKey
	AND fph.SeasonKey = dtd.SeasonKey
	AND fph.WasHome = dtd.IsTeamHome
	WHERE fph.PlayerKey = @PlayerKey
	AND fph.SeasonKey = @SeasonKey
	ORDER BY fph.GameweekKey;

END;