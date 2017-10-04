CREATE FUNCTION dbo.fnGetPlayerPointsByPlayerPosition
(
	@PlayerPositionKey INT,
	@SeasonKey INT,
	@MaxCost INT = NULL
)
RETURNS TABLE
AS
RETURN
(
	WITH PlayerPoints AS
	(
		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE pp.PlayerPositionKey = @PlayerPositionKey
		AND ph.SeasonKey = @SeasonKey
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort
	)
	SELECT points.PlayerKey,
	points.PlayerName,
	points.PlayerPositionShort AS PlayerPosition,
	t.TeamName AS teamName,
	pcs.Cost,
	points.TotalPoints
	FROM PlayerPoints points
	INNER JOIN dbo.DimPlayerAttribute pa
	ON points.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON points.PlayerKey = pcs.PlayerKey
	WHERE pcs.Cost <= ISNULL(@MaxCost,1000)
);