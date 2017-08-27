CREATE PROCEDURE dbo.GetPlayerPointsByPosition
(
	@playerPositionId INT = NULL
)
AS
BEGIN

	;WITH PlayerPoints AS
	(
		SELECT ph.playerId,
		SUM(ph.total_points) AS total_points
		FROM dbo.PlayerHistory ph
		INNER JOIN dbo.Players p
		ON ph.playerId = p.id
		INNER JOIN dbo.PlayerPositions pp
		ON p.playerPositionId = pp.id
		WHERE pp.id = @playerPositionId
		GROUP BY ph.playerId
	)
	SELECT p.id AS playerId,
	p.first_name + ' ' + p.second_name AS playerName,
	pp.singular_name_short AS playerPosition,
	t.name AS teamName,
	points.total_points AS points
	FROM dbo.Players p
	INNER JOIN dbo.PlayerPositions pp
	ON p.playerPositionId = pp.id
	INNER JOIN dbo.Teams t
	ON p.teamId = t.id
	INNER JOIN PlayerPoints points
	ON p.id = points.playerId
	WHERE pp.id = @playerPositionId
	ORDER BY points DESC;

END