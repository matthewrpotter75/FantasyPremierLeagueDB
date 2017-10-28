CREATE PROCEDURE dbo.GetMyTeamCurrentGameweek
(
	@SeasonKey INT = NULL,
	@CurrentGameweekKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @CurrentGameweekKey IS NULL
	BEGIN
		SET @CurrentGameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.MyTeam WHERE SeasonKey = @SeasonKey ORDER BY GameweekKey DESC);
	END

	SELECT dpp.PlayerPositionShort AS PlayerPosition, mt.PlayerKey, dp.PlayerName, dp.WebName, pcs.Cost, pcs.TotalPoints
	FROM dbo.MyTeam mt
	INNER JOIN dbo.DimPlayer dp
	ON mt.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON dp.PlayerKey = dpa.PlayerKey
	AND dpa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimPlayerPosition dpp
	ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON dp.PlayerKey = pcs.PlayerKey
	WHERE mt.SeasonKey = @SeasonKey
	AND GameweekKey = @CurrentGameweekKey
	ORDER BY dpp.PlayerPositionKey, dp.PlayerName;

END