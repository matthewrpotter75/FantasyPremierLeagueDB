CREATE PROCEDURE dbo.GetTotalPointsByPlayerPositionAndGameweekRange
(
	@SeasonKey INT,
	@GameweekStart INT = 1,
	@GameweekEnd INT = NULL,
	@MinutesLimit INT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @GameweekEnd IS NULL
	BEGIN
		SELECT @GameweekEnd = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE() 
	END

	SELECT dpp.PlayerPositionShort AS PlayerPosition, 
	SUM(fph.TotalPoints) AS TotalPoints, 
	COUNT(fph.PlayerHistoryKey) AS TotalGames,
	AVG(fph.TotalPoints * 1.00) AS AvgPoints
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON fph.PlayerKey = dpa.PlayerKey
	AND fph.SeasonKey = dpa.SeasonKey
	INNER JOIN dbo.DimPlayerPosition dpp
	ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
	WHERE fph.SeasonKey = @SeasonKey
	AND fph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	AND fph.[Minutes] > @MinutesLimit
	GROUP BY dpp.PlayerPositionKey, dpp.PlayerPositionShort
	ORDER BY dpp.PlayerPositionKey;

END;