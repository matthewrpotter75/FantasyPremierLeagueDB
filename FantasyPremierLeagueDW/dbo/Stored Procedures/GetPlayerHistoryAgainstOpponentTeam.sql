CREATE PROCEDURE dbo.GetPlayerHistoryAgainstOpponentTeam
(
	@PlayerKey INT = NULL,
	@PlayerName VARCHAR(100) = NULL,
	@OpponentTeamShortName VARCHAR(3),
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @OpponentTeamKey INT;

	IF @PlayerKey IS NULL AND @PlayerName IS NOT NULL
	BEGIN

		SELECT @PlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE PlayerName = @PlayerName;

	END

	IF @PlayerName IS NULL AND @PlayerKey IS NOT NULL
	BEGIN

		SELECT @PlayerName = PlayerName
		FROM dbo.DimPlayer
		WHERE PlayerKey = @PlayerKey;

	END

	SELECT @OpponentTeamKey = TeamKey
	FROM dbo.DimTeam
	WHERE TeamShortName = @OpponentTeamShortName;

	SELECT @PlayerName AS PlayerName;

	SELECT *
	FROM dbo.FactPlayerHistory
	WHERE PlayerKey = @PlayerKey
	AND OpponentTeamKey = @OpponentTeamKey
	ORDER BY SeasonKey, WasHome;

END