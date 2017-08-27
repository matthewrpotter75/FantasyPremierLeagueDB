CREATE PROCEDURE [dbo].[GetPlayerPointsByTeam]
(
	@teamId INT = NULL,
	@teamShortName VARCHAR(3) = NULL
)
--Examples
--EXEC [dbo].[GetPlayerPointsByTeam] @teamShortName = 'MCI';
--EXEC [dbo].[GetPlayerPointsByTeam] @teamId = 1;
AS
BEGIN

	IF @teamId IS NULL AND @teamShortName IS NOT NULL
	BEGIN

		SELECT @teamId = id
		FROM dbo.Teams
		WHERE short_name = @teamShortName;

	END

	;WITH PlayerPoints AS
	(
		SELECT ph.playerId,
		SUM(ph.total_points) AS playerPoints,
		SUM(CASE WHEN ph.[minutes] >= 60 THEN ph.total_points ELSE 0 END) AS playerPointsOver60,
		SUM(ph.[minutes]) AS playerMinutes,
		SUM(CASE WHEN ph.[minutes] > 0 THEN 1 ELSE 0 END) AS playerGames,
		SUM(CASE WHEN ph.[minutes] >= 60 THEN 1 ELSE 0 END) AS playerGamesOver60Min
		FROM dbo.PlayerHistory ph
		INNER JOIN dbo.Players p
		ON ph.playerId = p.id
		INNER JOIN dbo.Teams t
		ON p.teamId = t.id
		WHERE t.id = @teamId
		GROUP BY ph.playerId
	)
	SELECT p.id AS playerId,
	p.first_name + ' ' + p.second_name AS playerName,
	pp.singular_name_short AS playerPosition,
	t.name AS teamName,
	points.playerPoints,
	points.playerMinutes,
	points.playerGames,
	points.playerGamesOver60Min,
	CAST(ROUND(CASE WHEN points.playerGames <> 0 THEN (CAST(points.playerPoints AS DECIMAL(5,2))/points.playerGames) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGame,
	CAST(ROUND(CASE WHEN points.playerMinutes <> 0 THEN (CAST(points.playerPoints AS DECIMAL(5,2))/points.playerMinutes) * 90 ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerExtrapolatedGame,
	CAST(ROUND(CASE WHEN points.playerGamesOver60Min <> 0 THEN (CAST(points.playerPointsOver60 AS DECIMAL(5,2))/points.playerGamesOver60Min) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameOver60min
	FROM dbo.Players p
	INNER JOIN dbo.PlayerPositions pp
	ON p.playerPositionId = pp.id
	INNER JOIN dbo.Teams t
	ON p.teamId = t.id
	INNER JOIN PlayerPoints points
	ON p.id = points.playerId
	ORDER BY pp.id ASC, points.playerPoints DESC;

END