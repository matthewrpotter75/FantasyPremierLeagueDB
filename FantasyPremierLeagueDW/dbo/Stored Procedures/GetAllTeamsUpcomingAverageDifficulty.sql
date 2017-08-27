CREATE PROCEDURE dbo.GetAllTeamsUpcomingAverageDifficulty
(
	@SeasonId INT = NULL,
	@NextGameweekId INT = NULL,
	@NumGameweeks INT = 5
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonId IS NULL
	BEGIN
		SELECT @SeasonId = [SeasonKey] FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @LastGameweekId INT;
	IF @NextGameweekId IS NULL
	BEGIN
		SET @NextGameweekId = (SELECT TOP (1) [GameweekKey] FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	SET @LastGameweekId = @NextGameweekId + (@NumGameweeks - 1);

	SELECT dt.TeamShortName AS TeamName, 
	CAST(SUM(dtd.Difficulty * 1.00)/COUNT(dtd.Difficulty) AS DECIMAL(4,2)) AS averageDifficulty,
	SUM(dtd.Difficulty) AS sumDifficulty,
	COUNT(dtd.Difficulty) AS cntDifficulty
	FROM dbo.DimTeam dt
	INNER JOIN dbo.DimTeamGameweekFixture dtgwf
	ON dtgwf.TeamKey = dt.[TeamKey]
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON dtgwf.OpponentTeamKey = dtd.TeamKey
	AND dtgwf.IsHome = dtd.IsOpponentHome
	AND dtd.SeasonKey = @SeasonId
	INNER JOIN dbo.DimTeam dto
	ON dtgwf.OpponentTeamKey = dto.[TeamKey]
	WHERE dtgwf.SeasonKey = @SeasonId
	AND dtgwf.GameweekKey BETWEEN @NextGameweekId AND @LastGameweekId
	GROUP BY dt.TeamShortName;

END;