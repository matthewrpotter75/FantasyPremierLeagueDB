CREATE PROCEDURE dbo.GetPlayerCostSelectedExpectedPointsFormPoints
(
	@SeasonKey INT = NULL,
	@GameweekKey INT = NULL,
	@PlayerPositionKey INT = NULL,
	@MaxCost INT = 1000,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT p.PlayerKey, p.PlayerName, pgs.Cost, t.TeamName, pgs.SelectedByPercent, pgs.TotalPoints, pgs.ExpectedPointsNext, pgs.Form, pgs.TotalPoints
	FROM dbo.DimPlayer p
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.FactPlayerGameweekStatus pgs
	ON p.PlayerKey = pgs.PlayerKey
	AND pgs.SeasonKey = @SeasonKey
	AND pgs.GameweekKey = @GameweekKey
	WHERE pa.PlayerPositionKey = @PlayerPositionKey
	AND pgs.Cost <= @MaxCost
	ORDER BY pgs.TotalPoints DESC;

END