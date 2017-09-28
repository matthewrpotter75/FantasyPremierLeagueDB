CREATE PROCEDURE dbo.UpdatePossibleTeamIsPlayUsingGetPossibleTeamPlayerPointsForGameweek
(
	@SeasonKey INT = NULL,
	@GameweekKey INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	CREATE TABLE #BestTeam
	(
		PlayerKey INT,
		PlayerName VARCHAR(200),
		PlayerPositionShort VARCHAR(3),
		TotalPoints INT,
		PlayerPositionRank INT,
		OverallSquadPlayerRank INT,
		PlayerRank INT
	);

	INSERT INTO #BestTeam
	EXEC dbo.GetPossibleTeamPlayerPointsForGameweek @SeasonKey, @GameweekKey;

	UPDATE pt
	SET IsPlay = 1
	FROM dbo.PossibleTeam pt
	INNER JOIN #BestTeam bt
	ON pt.PlayerKey = bt.PlayerKey
	WHERE pt.SeasonKey = @SeasonKey
	AND pt.GameweekKey = @GameweekKey;

	UPDATE pt
	SET IsCaptain = 1
	FROM dbo.PossibleTeam pt
	INNER JOIN #BestTeam bt
	ON pt.PlayerKey = bt.PlayerKey
	WHERE pt.SeasonKey = @SeasonKey
	AND pt.GameweekKey = @GameweekKey
	AND bt.PlayerRank = 1;

END