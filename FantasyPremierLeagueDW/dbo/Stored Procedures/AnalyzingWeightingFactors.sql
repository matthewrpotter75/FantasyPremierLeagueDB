CREATE PROCEDURE dbo.AnalyzingWeightingFactors
(
	--DECLARE
	@Gameweeks INT = 5,
	@MinutesLimit INT = 30,
	@MaxPredictionPointsAllWeighting INT = 2,
	@MaxPredictionPoints5Weighting INT = 2,
	@MaxPredictionPoints10Weighting INT = 2,
	@Debug BIT = 0
)
AS
BEGIN

	BEGIN TRY

		SET NOCOUNT ON;

		DECLARE @GameweekKey INT, 
		@SeasonKey INT, 
		@PlayerPositionKey INT,
		@PlayerPosition VARCHAR(10),
		@Gameweek INT, 
		@GameweekCount INT,
		@GameweekEnd INT,
		@MaxGameweek INT, 
		@GameweekStartDate SMALLDATETIME, 
		@PredictionPointsAllWeighting INT, 
		@PredictionPoints5Weighting INT, 
		@PredictionPoints10Weighting INT,
		@TotalLoops BIGINT,
		@LoopCounter BIGINT,
		@ProgressPercentage DECIMAL(5,1),
		@ProgressPercentageString VARCHAR(10);

		IF OBJECT_ID('dbo.WeightingFactorsAnalysis') IS NOT NULL
			TRUNCATE TABLE dbo.WeightingFactorsAnalysis;

		IF OBJECT_ID('tempdb..#Gameweeks') IS NOT NULL
			DROP TABLE #Gameweeks;

		CREATE TABLE #Gameweeks
		(
			Id INT IDENTITY(1,1) NOT NULL,
			SeasonKey INT NOT NULL,
			GameweekKey INT NOT NULL
		);

		INSERT INTO #Gameweeks
		(SeasonKey, GameweekKey)
		SELECT SeasonKey, GameweekKey
		FROM dbo.DimGameweek gw
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.FactPlayerHistory
			WHERE SeasonKey = gw.SeasonKey
			AND GameweekKey = gw.GameweekKey + 5
		)
		ORDER BY SeasonKey, GameweekKey;

		SELECT @GameweekCount = COUNT(1) FROM #Gameweeks;
		SELECT @TotalLoops = 4 * @GameweekCount * @MaxPredictionPointsAllWeighting * @MaxPredictionPoints5Weighting * @MaxPredictionPoints10Weighting;

		--SELECT *
		--FROM #Gameweeks;

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

		SELECT @MaxGameweek = MAX(Id) FROM #Gameweeks;

		SELECT @Gameweeks AS Gameweeks, @MaxGameweek AS TotalGameweeks, @MaxPredictionPointsAllWeighting AS MaxPredictionPointsAllWeighting, @MaxPredictionPoints5Weighting AS MaxPredictionPoints5Weighting, @MaxPredictionPoints10Weighting AS MaxPredictionPoints10Weighting, @TotalLoops AS TotalLoops;

		SET @PlayerPositionKey = 1;
		SET @Gameweek = 1;
		SET @LoopCounter = 1;

		SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
		SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));

		WHILE @PlayerPositionKey <= 4
		BEGIN

			SELECT @PlayerPosition = SingularNameShort FROM dbo.DimPlayerPosition WHERE PlayerPositionKey = @PlayerPositionKey
			RAISERROR('PlayerPosition: %s', 0, 1, @PlayerPosition) WITH NOWAIT;

			WHILE @Gameweek <= @MaxGameweek
			BEGIN

				SET @PredictionPointsAllWeighting = 1;
				SET @PredictionPoints5Weighting = 1;
				SET @PredictionPoints10Weighting = 1;

				SELECT @GameweekKey = GameweekKey, @SeasonKey = SeasonKey FROM #Gameweeks WHERE Id = @Gameweek;
				SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @Gameweek;
			
				RAISERROR('SeasonKey: %d GameweekKey: %d (%d out of %d)', 0, 1, @SeasonKey, @GameweekKey, @LoopCounter, @TotalLoops) WITH NOWAIT;

				WHILE @PredictionPointsAllWeighting <= @MaxPredictionPointsAllWeighting
				BEGIN

					WHILE @PredictionPoints5Weighting <= @MaxPredictionPoints5Weighting
					BEGIN

						WHILE @PredictionPoints10Weighting <= @MaxPredictionPoints10Weighting
						BEGIN

							RAISERROR('PredictionPointsAllWeighting: %d PredictionPoints5Weighting: %d PredictionPoints10Weighting: %d (%s%)', 0, 1, @PredictionPointsAllWeighting, @PredictionPoints5Weighting, @PredictionPoints10Weighting, @ProgressPercentageString) WITH NOWAIT;

							EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing
							@SeasonKey = @SeasonKey,
							@Gameweeks = 5,
							@GameweekStart = @Gameweek,
							@GameweekStartDate = @GameweekStartDate,
							@GameweekEnd = @GameweekEnd,
							@PlayerPositionKey = @PlayerPositionKey,
							@MinutesLimit = @MinutesLimit,
							@PredictionPointsAllWeighting = @PredictionPointsAllWeighting,
							@PredictionPoints5Weighting = @PredictionPoints5Weighting,
							@PredictionPoints10Weighting = @PredictionPoints10Weighting,
							@NumOfRowsToReturn = 200;
							
							INSERT INTO dbo.WeightingFactorsAnalysis
							SELECT *
							FROM #FinalPrediction;
							
							DELETE FROM #FinalPrediction;		

							SET @LoopCounter = @LoopCounter + 1;
							SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
							SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));
							SET @PredictionPoints10Weighting = @PredictionPoints10Weighting + 1;

						END

						SET @PredictionPoints5Weighting = @PredictionPoints5Weighting + 1;
						SET @PredictionPoints10Weighting = 1;

					END

					SET @PredictionPointsAllWeighting = @PredictionPointsAllWeighting + 1;
					SET @PredictionPoints5Weighting = 1;
					SET @PredictionPoints10Weighting = 1;

				END

				SET @Gameweek = @Gameweek + 1;
				SET @PredictionPointsAllWeighting = 1;
				SET @PredictionPoints5Weighting = 1;
				SET @PredictionPoints10Weighting = 1;

			END
			RAISERROR('Completed!!! (%s%)', 0, 1, @ProgressPercentageString) WITH NOWAIT;

			SET @PlayerPositionKey = @PlayerPositionKey + 1;
			SET @Gameweek = 1;
			SET @PredictionPointsAllWeighting = 1;
			SET @PredictionPoints5Weighting = 1;
			SET @PredictionPoints10Weighting = 1;

		END

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