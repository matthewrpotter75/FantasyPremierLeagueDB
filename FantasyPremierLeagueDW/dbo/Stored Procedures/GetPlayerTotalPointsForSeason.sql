CREATE PROCEDURE dbo.GetPlayerTotalPointsForSeason
(
	@SeasonKey INT,
	@PlayerKey INT = NULL
)
AS
BEGIN

	IF @PlayerKey IS NOT NULL
	BEGIN

		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort,
		COUNT(ph.PlayerHistoryKey) AS TotalGames,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE ph.PlayerKey = @PlayerKey
		AND ph.SeasonKey = @SeasonKey
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort;

	END
	ELSE
	BEGIN

		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort,
		COUNT(ph.PlayerHistoryKey) AS TotalGames,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE ph.SeasonKey = @SeasonKey
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort;
	
	END

END