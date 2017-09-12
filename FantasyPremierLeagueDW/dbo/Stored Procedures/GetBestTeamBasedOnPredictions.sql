--CREATE PROCEDURE dbo.GetBestTeamBasedOnPredictions
--(
	DECLARE
	@SeasonKey INT = NULL,
	@Gameweeks INT = 5,
	@MinutesLimit INT = 30,
	@Debug BIT = 0,
	@GameweekStart INT = NULL
--)
--AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Gameweek INT, @GameweekEnd INT;
	DECLARE @PlayerPositionKey INT = 1;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	--Get next gameweek
	IF @GameweekStart IS NULL
	BEGIN

		SELECT @GameweekStart =
		(
			SELECT TOP 1 GameweekKey
			FROM dbo.DimGameweek
			WHERE DATEADD(hour,1,DeadlineTime) > GETDATE()
			ORDER BY DeadlineTime
		);

	END

	--Get end of gameweek range
	SET @GameweekEnd = @GameweekStart + (@Gameweeks - 1);

	IF OBJECT_ID('tempdb..#Players') IS NOT NULL
		DROP TABLE #Players;

	IF OBJECT_ID('tempdb..#SelectedTopPlayers') IS NOT NULL
		DROP TABLE #SelectedTopPlayers;

	CREATE TABLE #Players 
	(
		SeasonKey INT,
		GameweekStartKey INT,
		Gameweeks INT,
		PlayerPositionKey INT,
		PlayerKey INT,
		PlayerName VARCHAR(100),
		Cost INT,
		PlayerPosition VARCHAR(3),
		TeamName VARCHAR(100),
		CurrentPoints INT,
		TotalGames INT,
		PredictedPoints DECIMAL(10,6)
	);

	SELECT @SeasonKey AS SeasonKey, @GameweekStart AS GameweekStart, @GameweekEnd AS GameweekEnd, @Gameweeks AS Gameweeks;

	SET @Gameweek = @GameweekStart;

	WHILE @PlayerPositionKey <= 4
	BEGIN

		RAISERROR('Gameweek %d starting', 0, 1, @Gameweek) WITH NOWAIT;

		SET @Gameweek = @GameweekStart;

		INSERT INTO #Players
		EXEC dbo.FutureFixturePlayerPointsPredictions
		@SeasonKey = @SeasonKey,
		@Gameweeks = 5,
		@GameweekStart = @Gameweek,
		@PlayerPositionKey = @PlayerPositionKey,
		@MinutesLimit = @MinutesLimit;

		WHILE @Gameweek <= @GameweekEnd
		BEGIN

			RAISERROR('Gameweek %d PlayerPosition %d', 0, 1, @Gameweek, @PlayerPositionKey) WITH NOWAIT;

			INSERT INTO #Players
			EXEC dbo.FutureFixturePlayerPointsPredictions
			@SeasonKey = @SeasonKey,
			@Gameweeks = 1,
			@GameweekStart = @Gameweek,
			@PlayerPositionKey = @PlayerPositionKey,
			@MinutesLimit = @MinutesLimit;

			SET @Gameweek = @Gameweek + 1;

		END

		SET @PlayerPositionKey = @PlayerPositionKey + 1;

	END

	SELECT *,
	(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
	FROM #Players
	ORDER BY GameweekStartKey, Gameweeks DESC, PlayerPositionKey, PredictedPoints DESC;

	CREATE TABLE #SelectedTopPlayers 
	(
		SeasonKey INT,
		GameweekStartKey INT,
		Gameweeks INT,
		PlayerPositionKey INT,
		PlayerKey INT,
		PlayerName VARCHAR(100),
		Cost INT,
		PlayerPosition VARCHAR(3),
		TeamName VARCHAR(100),
		CurrentPoints INT,
		TotalGames INT,
		PredictedPoints DECIMAL(10,6),
		PredictedPointsPerCost DECIMAL(10,6)
	);

	INSERT INTO #SelectedTopPlayers
	SELECT TOP (2) *,
	(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
	FROM #Players
	WHERE PlayerPosition = 'GKP'
	AND Gameweeks = 5
	ORDER BY PredictedPoints DESC;

	INSERT INTO #SelectedTopPlayers
	SELECT TOP (5) *,
	(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
	FROM #Players
	WHERE PlayerPosition = 'DEF'
	AND Gameweeks = 5
	ORDER BY PredictedPoints DESC;

	INSERT INTO #SelectedTopPlayers
	SELECT TOP (5) *,
	(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
	FROM #Players
	WHERE PlayerPosition = 'MID'
	AND Gameweeks = 5
	ORDER BY PredictedPoints DESC;

	INSERT INTO #SelectedTopPlayers
	SELECT TOP (3) *,
	(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
	FROM #Players
	WHERE PlayerPosition = 'FWD'
	AND Gameweeks = 5
	ORDER BY PredictedPoints DESC;

	SELECT *
	FROM #SelectedTopPlayers
	ORDER BY PlayerPositionKey, PredictedPoints DESC;

	SELECT TeamName, COUNT(*) AS PlayerCount
	FROM #SelectedTopPlayers
	GROUP BY TeamName
	ORDER BY TeamName;

	SELECT PlayerPosition, SUM(Cost) AS TotalCost
	FROM #SelectedTopPlayers
	GROUP BY PlayerPosition, PlayerPositionKey
	ORDER BY PlayerPositionKey;

	SELECT SUM(Cost) AS TotalCost
	FROM #SelectedTopPlayers;

END