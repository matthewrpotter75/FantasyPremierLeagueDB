CREATE PROCEDURE dbo.GetPlayerTotalPointsForSeasonMultiplePlayers
(
	@SeasonKey INT,
	@PlayerKeys VARCHAR(200) = NULL
)
AS
BEGIN

	IF @PlayerKeys IS NOT NULL
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
		AND ph.[Minutes] > 0
		AND ph.PlayerKey IN
		(
			SELECT Term AS PlayerKey
			FROM dbo.fnSplit(@PlayerKeys, ',')
		)
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort, pp.PlayerPositionKey
		ORDER BY pp.PlayerPositionKey, p.PlayerName;

	END
	ELSE
	BEGIN

		SELECT ph.PlayerKey,
		p.PlayerName,
		t.TeamShortName AS TeamName,
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
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.[Minutes] > 0
		GROUP BY ph.PlayerKey, p.PlayerName, t.TeamShortName, pp.PlayerPositionShort, pp.PlayerPositionKey
		ORDER BY pp.PlayerPositionKey, TotalPoints DESC, PlayerName;
	
	END

END