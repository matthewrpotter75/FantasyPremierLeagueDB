CREATE PROCEDURE dbo.GetBestTeamBasedOnPredictions
(
	--DECLARE
	@SeasonKey INT = NULL,
	@Gameweeks INT = 5,
	@MinutesLimit INT = 30,
	@Debug BIT = 0,
	@GameweekStart INT = NULL
)
AS
BEGIN

	BEGIN TRY

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

			RAISERROR('PlayerPositionKey %d starting', 0, 1, @PlayerPositionKey) WITH NOWAIT;

			SET @Gameweek = @GameweekStart;

			INSERT INTO #Players
			EXEC dbo.FutureFixturePlayerPointsPredictionsRefactored
			@SeasonKey = @SeasonKey,
			@Gameweeks = 5,
			@GameweekStart = @Gameweek,
			@PlayerPositionKey = @PlayerPositionKey,
			@MinutesLimit = @MinutesLimit;

			WHILE @Gameweek <= @GameweekEnd
			BEGIN

				RAISERROR('Gameweek %d PlayerPosition %d', 0, 1, @Gameweek, @PlayerPositionKey) WITH NOWAIT;

				INSERT INTO #Players
				EXEC dbo.FutureFixturePlayerPointsPredictionsRefactored
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

		;WITH MaxPointsGKP AS
		(
			SELECT MAX(PlayerPositionKey) AS PlayerPositionKey,
			MAX(CurrentPoints) AS MaxCurrentPoints
			FROM #Players
			WHERE PlayerPositionKey = 1
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
		),
		MaxPointsDEF AS
		(
			SELECT MAX(PlayerPositionKey) AS PlayerPositionKey,
			MAX(CurrentPoints) AS MaxCurrentPoints
			FROM #Players
			WHERE PlayerPositionKey = 2
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
		),
		MaxPointsMID AS
		(
			SELECT MAX(PlayerPositionKey) AS PlayerPositionKey,
			MAX(CurrentPoints) AS MaxCurrentPoints
			FROM #Players
			WHERE PlayerPositionKey = 3
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
		),
		MaxPointsFWD AS
		(
			SELECT MAX(PlayerPositionKey) AS PlayerPositionKey,
			MAX(CurrentPoints) AS MaxCurrentPoints
			FROM #Players
			WHERE PlayerPositionKey = 4
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
		),
		GKPRanked AS
		(
			SELECT PlayerKey,
			p.PlayerPositionKey,
			PlayerPosition,
			CurrentPoints,
			PredictedPoints,
			Cost,
			ROW_NUMBER() OVER (ORDER BY CurrentPoints DESC) AS PlayerRank
			FROM #Players p
			INNER JOIN MaxPointsGKP maxPts
			ON p.PlayerPositionKey = maxPts.PlayerPositionKey
			WHERE p.PlayerPositionKey = 1
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
			AND p.CurrentPoints > maxPts.MaxCurrentPoints - 10
		),
		DEFRanked AS
		(
			SELECT PlayerKey,
			p.PlayerPositionKey,
			PlayerPosition,
			CurrentPoints,
			PredictedPoints,
			Cost,
			ROW_NUMBER() OVER (ORDER BY CurrentPoints DESC) AS PlayerRank
			FROM #Players p
			INNER JOIN MaxPointsDEF maxPts
			ON p.PlayerPositionKey = maxPts.PlayerPositionKey
			WHERE p.PlayerPositionKey = 2
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
			AND p.CurrentPoints > maxPts.MaxCurrentPoints - 10
		),
		MIDRanked AS
		(
			SELECT PlayerKey,
			p.PlayerPositionKey,
			PlayerPosition,
			CurrentPoints,
			PredictedPoints,
			Cost,
			ROW_NUMBER() OVER (ORDER BY CurrentPoints DESC) AS PlayerRank
			FROM #Players p
			INNER JOIN MaxPointsMID maxPts
			ON p.PlayerPositionKey = maxPts.PlayerPositionKey
			WHERE p.PlayerPositionKey = 3
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
			AND p.CurrentPoints > maxPts.MaxCurrentPoints - 10
		),
		FWDRanked AS
		(
			SELECT PlayerKey,
			p.PlayerPositionKey,
			PlayerPosition,
			CurrentPoints,
			PredictedPoints,
			Cost,
			ROW_NUMBER() OVER (ORDER BY CurrentPoints DESC) AS PlayerRank
			FROM #Players p
			INNER JOIN MaxPointsFWD maxPts
			ON p.PlayerPositionKey = maxPts.PlayerPositionKey
			WHERE p.PlayerPositionKey = 4
			AND GameweekStartKey = @GameweekStart
			AND Gameweeks = 5
			AND p.CurrentPoints > maxPts.MaxCurrentPoints - 10
		),
		TopPointsPerCostGKP AS
		(
			SELECT TOP 5 rnk.*,
			p.PlayerName,
			(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
			FROM GKPRanked rnk
			INNER JOIN dbo.DimPlayer p
			ON rnk.PlayerKey = p.PlayerKey
			WHERE PlayerRank <= 10
			ORDER BY PredictedPointsPerCost DESC
		),
		TopPointsPerCostDEF AS
		(
			SELECT TOP 10 rnk.*,
			p.PlayerName,
			(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
			FROM DEFRanked rnk
			INNER JOIN dbo.DimPlayer p
			ON rnk.PlayerKey = p.PlayerKey
			WHERE PlayerRank <= 20
			ORDER BY PredictedPointsPerCost DESC
		),
		TopPointsPerCostMID AS
		(
			SELECT TOP 10 rnk.*,
			p.PlayerName,
			(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
			FROM MIDRanked rnk
			INNER JOIN dbo.DimPlayer p
			ON rnk.PlayerKey = p.PlayerKey
			WHERE PlayerRank <= 20
			ORDER BY PredictedPointsPerCost DESC
		),
		TopPointsPerCostFWD AS
		(
			SELECT TOP 10 rnk.*,
			p.PlayerName,
			(PredictedPoints * 1.00)/(Cost * 0.10) AS PredictedPointsPerCost
			FROM FWDRanked rnk
			INNER JOIN dbo.DimPlayer p
			ON rnk.PlayerKey = p.PlayerKey
			WHERE PlayerRank <= 20
			ORDER BY PredictedPointsPerCost DESC
		)
		SELECT *
		FROM TopPointsPerCostGKP

		UNION

		SELECT *
		FROM TopPointsPerCostDEF

		UNION

		SELECT *
		FROM TopPointsPerCostMID

		UNION

		SELECT *
		FROM TopPointsPerCostFWD
		
		ORDER BY PlayerPositionKey, PredictedPointsPerCost DESC;

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

	END TRY
	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		RAISERROR
		(
			@ErrorMessage, -- Message text
			@ErrorSeverity, -- Severity
			@ErrorState -- State
		);

	END CATCH

END