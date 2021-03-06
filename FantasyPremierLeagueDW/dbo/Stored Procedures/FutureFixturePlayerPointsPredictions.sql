CREATE PROCEDURE dbo.FutureFixturePlayerPointsPredictions
(
	--DECLARE
	@SeasonKey INT = NULL,
	@Gameweeks INT = 5,
	@PlayerPositionKey INT = 2,
	@MinutesLimit INT = 30,
	@Debug BIT = 0,
	@TimerDebug BIT = 0,
	@PlayerKey INT = NULL,
	@GameweekStart INT = NULL,
	@NumOfRowsToReturn INT = 20
)
AS
BEGIN
	
	BEGIN TRY

		SET NOCOUNT ON;

		--TODO: 
		--Limit PPG calculation to where player hasn't moved clubs or has moved to equal club or better club

		DECLARE @SeasonEnd INT, @GameweekEnd INT, @Gameweek INT, @GameweekStartDate DATE, @time DATETIME;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='Starting', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

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

		SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekStart;

		--Get end of gameweek range
		SET @GameweekEnd = @GameweekStart + (@Gameweeks - 1);
		SET @SeasonEnd = @SeasonKey;

		--Create temp table to hold final results from child stored procedure
		CREATE TABLE #FinalPrediction
		(
			SeasonKey INT,
			GameweekStartKey INT,
			Gameweeks INT,
			PlayerPositionKey INT,
			PredictionPointsAllWeighting INT,
			PredictionPoints5Weighting INT,
			PredictionPoints10Weighting INT,
			PlayerKey INT,
			PlayerName VARCHAR(100),
			Cost INT,
			PlayerPosition VARCHAR(3),
			TeamName VARCHAR(50),
			TotalPlayerGames INT,
			TotalPlayerMinutes INT,
			CurrentPoints INT,
			PredictedPointsAll DECIMAL(6,2),
			PredictedPoints5 DECIMAL(6,2),
			PredictedPoints10 DECIMAL(6,2),
			OverallPPGPredictionPoints DECIMAL(10,6),
			OverallTeamPPGPredictionPoints DECIMAL(10,6),
			OverallDifficultyPPGPredictionPoints DECIMAL(10,6),
			OverallFractionOfMinutesPlayed DECIMAL(10,6),
			Prev5FractionOfMinutesPlayed DECIMAL(10,6),
			StartingProbability DECIMAL(10,6),
			TotalGames INT,
			TeamTotalGames INT,
			DifficultyTotalGames INT,
			PredictedPointsPath INT,
			PredictedPoints DECIMAL(10,6),
			PredictedPointsWeighted DECIMAL(10,6),
			ChanceOfPlayingNextRound DECIMAL(6,2)
		);

		IF @Debug = 1
		BEGIN

			SELECT @SeasonKey AS SeasonKey,
			@Gameweeks AS Gameweeks,
			@PlayerPositionKey AS PlayerPositionKey,
			@MinutesLimit AS MintutesLimit,
			@Debug AS Debug,
			@TimerDebug AS TimerDebug,
			@PlayerKey AS PlayerKey,
			@GameweekStart AS GameweekStart,
			@GameweekEnd AS GameweekEnd,
			@SeasonEnd AS SeasonEnd,
			@GameweekStartDate AS GameweekStartDate;
			
			SELECT 'EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing' +
			CAST(@SeasonKey AS VARCHAR(3)) + ',' +
			CAST(@Gameweeks AS VARCHAR(3)) + ',' +
			CAST(@PlayerPositionKey AS VARCHAR(3)) + ',' +
			CAST(@MinutesLimit AS VARCHAR(3)) + ',' +
			CAST(@Debug AS VARCHAR(3)) + ',' +
			CAST(@TimerDebug AS VARCHAR(3)) + ',' +
			ISNULL(CAST(@PlayerKey AS VARCHAR(3)),NULL) + ',' +
			CAST(@GameweekStart AS VARCHAR(3)) + ',' +
			CAST(@GameweekEnd AS VARCHAR(3)) + ',' +
			CAST(@SeasonEnd AS VARCHAR(3)) + ',
			''' + ISNULL(CAST(@GameweekStartDate AS VARCHAR(20)),'NULL') + '';
			
		END

		EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing
			@SeasonKey,
			@Gameweeks,
			@PlayerPositionKey,
			@MinutesLimit,
			@Debug,
			@TimerDebug,
			@PlayerKey,
			@GameweekStart,
			@GameweekEnd,
			@SeasonEnd,
			@GameweekStartDate;
	
			--Output final prediction
			SELECT TOP (@NumOfRowsToReturn)
				SeasonKey,
				GameweekStartKey,
				Gameweeks,
				PlayerPositionKey,
				PlayerKey,
				PlayerName,
				Cost,
				PlayerPosition,
				TeamName,
				CurrentPoints,
				TotalGames,
				PredictedPointsWeighted
			FROM #FinalPrediction
			ORDER BY PredictedPointsWeighted DESC;

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