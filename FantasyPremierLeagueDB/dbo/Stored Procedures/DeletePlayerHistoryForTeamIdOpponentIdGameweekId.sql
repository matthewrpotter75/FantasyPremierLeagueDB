CREATE PROCEDURE dbo.DeletePlayerHistoryForTeamIdOpponentIdGameweekId
(
	@GameweekId INT,
	@TeamId INT,
	@OpponentTeamId INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @Debug = 1
	BEGIN

		SELECT p.web_name, ph.*
		FROM dbo.PlayerHistory ph
		INNER JOIN dbo.Players p
		ON ph.playerId = p.id
		WHERE gameweekId = @GameweekId
		AND
		(
			opponent_teamId = @TeamId
			OR
			opponent_teamId = @OpponentTeamId
		)
		ORDER BY was_home DESC;

	END
	ELSE
	BEGIN

		DELETE ph
		FROM dbo.PlayerHistory ph
		INNER JOIN dbo.Players p
		ON ph.playerId = p.id
		WHERE gameweekId = @GameweekId
		AND
		(
			opponent_teamId = @TeamId
			OR
			opponent_teamId = @OpponentTeamId
		);

	END

END
GO