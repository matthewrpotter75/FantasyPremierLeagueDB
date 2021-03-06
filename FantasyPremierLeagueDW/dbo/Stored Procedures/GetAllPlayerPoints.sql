CREATE PROCEDURE dbo.GetAllPlayerPoints
(
	@SeasonKey INT = 12
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT ph.PlayerKey,
	p.PlayerName,
	pp.PlayerPositionShort AS PlayerPosition,
	t.TeamName,
	pcs.Cost,
	SUM(ph.TotalPoints) AS TotalPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer p
	ON ph.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	AND ph.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON ph.PlayerKey = pcs.PlayerKey
	GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort, t.TeamName, pcs.Cost
	ORDER BY pcs.Cost DESC;

END
