CREATE PROCEDURE dbo.GetTotalPointsByTeamAndPlayerPositionAndGameweekRange
(
	@SeasonKey INT,
	@StartGameweekKey INT = 1,
	@EndGameweekKey INT = NULL,
	@MinMinutesPlayed INT = 30
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @EndGameweekKey IS NULL
	BEGIN
		SELECT @EndGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE() 
	END


	SELECT dt.TeamShortName AS TeamName, 
	dpp.PlayerPositionShort AS PlayerPosition, 
	SUM(fph.TotalPoints) AS TotalPoints,
	COUNT(fph.PlayerHistoryKey) AS TotalGames,
	AVG(fph.TotalPoints * 1.00) AS AvgPoints
	FROM dbo.FactPlayerHistory fph
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON fph.PlayerKey = dpa.PlayerKey
	AND fph.SeasonKey = dpa.SeasonKey
	INNER JOIN dbo.DimTeam dt
	ON dpa.TeamKey = dt.TeamKey
	INNER JOIN dbo.DimPlayerPosition dpp
	ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
	WHERE fph.SeasonKey = @SeasonKey
	AND fph.GameweekKey BETWEEN @StartGameweekKey AND @EndGameweekKey
	AND fph.[Minutes] > @MinMinutesPlayed
	GROUP BY dt.TeamShortName, dpp.PlayerPositionKey, dpp.PlayerPositionShort
	ORDER BY dt.TeamShortName, dpp.PlayerPositionKey;

END;