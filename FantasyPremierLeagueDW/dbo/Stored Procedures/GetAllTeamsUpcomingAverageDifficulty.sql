CREATE PROCEDURE dbo.GetAllTeamsUpcomingAverageDifficulty
(
	@SeasonKey INT = NULL,
	@NextGameweekKey INT = NULL,
	@NumGameweeks INT = 5
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @LastGameweekKey INT;
	IF @NextGameweekKey IS NULL
	BEGIN
		SET @NextGameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	SET @LastGameweekKey = @NextGameweekKey + (@NumGameweeks - 1);

	SELECT dt.TeamShortName AS TeamName, 
	CAST(SUM(dtd.Difficulty * 1.00)/COUNT(dtd.Difficulty) AS DECIMAL(4,2)) AS AverageDifficulty,
	SUM(dtd.Difficulty) AS sumDifficulty,
	COUNT(dtd.Difficulty) AS cntDifficulty
	FROM dbo.DimTeam dt
	INNER JOIN dbo.DimTeamGameweekFixture dtgwf
	ON dtgwf.TeamKey = dt.TeamKey
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON dtgwf.OpponentTeamKey = dtd.TeamKey
	AND dtgwf.IsHome = dtd.IsOpponentHome
	AND dtd.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeam dto
	ON dtgwf.OpponentTeamKey = dto.TeamKey
	WHERE dtgwf.SeasonKey = @SeasonKey
	AND dtgwf.GameweekKey BETWEEN @NextGameweekKey AND @LastGameweekKey
	GROUP BY dt.TeamShortName;

END;