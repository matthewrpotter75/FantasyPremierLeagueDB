CREATE FUNCTION dbo.fnGetOverallPPG
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@MinutesLimit INT
)
RETURNS TABLE
AS
RETURN
(
	--Create temp table with overall points per game
	SELECT ph.PlayerKey,
	ph.PlayerPositionKey,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.PlayerKey) AS Games,
	SUM(ph.[Minutes]) AS PlayerMinutes,
	--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG
	FROM dbo.fnGetPlayerHistoryRankedByPoints(@SeasonKey,@PlayerPositionKey,@MinutesLimit) ph
	WHERE ph.PointsGameweekRank > 1
	GROUP BY ph.PlayerKey, ph.PlayerPositionKey
);