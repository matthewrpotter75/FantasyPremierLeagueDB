CREATE FUNCTION dbo.fnGetPlayerHistoryRankedByGameweek
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
		SELECT PlayerKey,
		SeasonKey,
		GameweekKey,
		ROW_NUMBER() OVER (PARTITION BY PlayerKey ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc,
		TotalPoints,
		[Minutes],
		WasHome,
		OpponentTeamKey,
		PlayerPositionKey
		FROM dbo.fnGetPlayerHistoryRankedByPoints(@SeasonKey,@PlayerPositionKey,@MinutesLimit)
		WHERE [Minutes] > @MinutesLimit
		AND PointsGameweekRank > 1
);