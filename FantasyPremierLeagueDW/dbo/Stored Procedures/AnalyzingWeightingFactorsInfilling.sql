CREATE PROCEDURE dbo.AnalyzingWeightingFactorsInfilling
(
	--DECLARE
	@Gameweeks INT = 5,
	@MinutesLimit INT = 30,
	@MaxPredictionPointsAllWeighting INT = 2,
	@MaxPredictionPoints5Weighting INT = 2,
	@MaxPredictionPoints10Weighting INT = 2,
	@Debug BIT = 0,
	@DebugExec BIT = 0
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
		@SeasonEnd INT,
		@GameweekEnd INT,
		@MaxGameweek INT, 
		@GameweekStartDate SMALLDATETIME, 
		@PredictionPointsAllWeighting INT, 
		@PredictionPoints5Weighting INT, 
		@PredictionPoints10Weighting INT,
		@TotalLoops BIGINT,
		@LoopCounter BIGINT,
		@ProgressPercentage DECIMAL(5,1),
		@ProgressPercentageString VARCHAR(10),
		@CurrentTime VARCHAR(20),
		@MaxWeightingFactorsAnalysisKey INT;

		DECLARE @i INT, @j INT, @k INT;
		DECLARE @PredictionPointWeighting TABLE (PredictionPointsAllWeighting INT, PredictionPoints5Weighting INT, PredictionPoints10Weighting INT);

		SET @i = 1;
		SET @j = 1;
		SET @k = 1;

		WHILE @i <= @MaxPredictionPointsAllWeighting
		BEGIN

			WHILE @j <= @MaxPredictionPoints5Weighting
			BEGIN

				WHILE @k <= @MaxPredictionPoints10Weighting
				BEGIN

					INSERT INTO @PredictionPointWeighting
					VALUES (@i, @j, @k);

					SET @k = @k + 1;

				END

				SET @k = 1;
				SET @j = @j + 1;
		

			END

			SET @j = 1;
			SET @i = @i + 1;

		END

		IF OBJECT_ID('tempdb..#Gameweeks') IS NOT NULL
			DROP TABLE #Gameweeks;

		IF OBJECT_ID('tempdb..#AllFactors') IS NOT NULL
			DROP TABLE #AllFactors;

		IF OBJECT_ID('tempdb..#InfillFactors') IS NOT NULL
			DROP TABLE #InfillFactors;
		
		DECLARE @PlayerPositionKeys TABLE (PlayerPositionKey INT);

		INSERT INTO @PlayerPositionKeys
		VALUES (1),(2),(3),(4)

		CREATE TABLE #Gameweeks
		(
			Id INT IDENTITY(1,1) NOT NULL,
			SeasonKey INT NOT NULL,
			GameweekKey INT NOT NULL
		);

		;WITH GameweeksRanked AS
		(
			SELECT SeasonKey, 
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekRank
			FROM dbo.DimGameweek gw
			WHERE DeadlineTime < GETDATE()
		)
		INSERT INTO #Gameweeks
		(SeasonKey, GameweekKey)
		SELECT SeasonKey, GameweekKey
		FROM GameweeksRanked
		WHERE GameweekRank > 5
		ORDER BY SeasonKey, GameweekKey;

		CREATE TABLE #AllFactors
		(
			Id INT IDENTITY(1,1),
			PlayerPositionKey INT, 
			SeasonKey INT, 
			GameweekKey INT, 
			PredictionPointsAllWeighting INT, 
			PredictionPoints5Weighting INT, 
			PredictionPoints10Weighting INT
		);

		INSERT INTO #AllFactors
		(PlayerPositionKey, SeasonKey, GameweekKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting)
		SELECT PlayerPositionKey, SeasonKey, GameweekKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting
		FROM @PlayerPositionKeys
		CROSS APPLY #Gameweeks
		CROSS APPLY @PredictionPointWeighting
		ORDER BY PlayerPositionKey, SeasonKey, GameweekKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting;

		SELECT @MaxWeightingFactorsAnalysisKey = MAX(WeightingFactorsAnalysisKey) FROM dbo.WeightingFactorsAnalysis;

		--SELECT @PlayerPositionKey = PlayerPositionKey,
		--@SeasonKey = SeasonKey,
		--@GameweekKey = GameweekStartKey,
		--@PredictionPointsAllWeighting = PredictionPointsAllWeighting,
		--@PredictionPoints5Weighting = PredictionPoints5Weighting,
		--@PredictionPoints10Weighting = PredictionPoints10Weighting
		--FROM dbo.WeightingFactorsAnalysis
		--WHERE WeightingFactorsAnalysisKey = @MaxWeightingFactorsAnalysisKey;

		--SELECT @Gameweek = Id FROM #Gameweeks WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;

		CREATE TABLE #InfillFactors
		(
			Id INT IDENTITY(1,1),
			PlayerPositionKey INT, 
			SeasonKey INT, 
			GameweekKey INT, 
			PredictionPointsAllWeighting INT, 
			PredictionPoints5Weighting INT, 
			PredictionPoints10Weighting INT
		);

		INSERT INTO #InfillFactors
		(PlayerPositionKey, SeasonKey, GameweekKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting)
		SELECT PlayerPositionKey, SeasonKey, GameweekKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting
		FROM #AllFactors af
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM dbo.WeightingFactorsAnalysis
			WHERE PlayerPositionKey = af.PlayerPositionKey
			AND SeasonKey = af.SeasonKey
			AND GameweekKey = af.GameweekKey
			AND PredictionPointsAllWeighting = af.PredictionPointsAllWeighting
			AND PredictionPoints5Weighting = af.PredictionPoints5Weighting
			AND PredictionPoints10Weighting = af.PredictionPoints10Weighting
		)
		AND af.Id < @MaxWeightingFactorsAnalysisKey
		ORDER BY PlayerPositionKey, SeasonKey, GameweekKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting;

		IF @Debug = 1
		BEGIN

			SELECT *
			FROM #Gameweeks
			ORDER BY SeasonKey, GameweekKey;

			SELECT *
			FROM #InfillFactors
			ORDER BY Id;

		END

		--SELECT @MaxGameweek = MAX(Id) FROM #Gameweeks;
		--SELECT @GameweekCount = COUNT(1) FROM #Gameweeks;
		SELECT @TotalLoops = COUNT(1) FROM #InfillFactors;

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

		SELECT @LoopCounter = 1;
		IF @TotalLoops <> 0
			SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
		ELSE
			SELECT @ProgressPercentage = 0;

		SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));

		DECLARE @sTotalLoops VARCHAR(10);

		IF @TotalLoops > 1000
			SELECT @sTotalLoops = CAST(@TotalLoops/1000 AS VARCHAR(10)) + ',' + RIGHT('000' + CAST(@TotalLoops - ((@TotalLoops/1000) * 1000) AS VARCHAR(10)), 3);
		ELSE
			SELECT @sTotalLoops = CAST(@TotalLoops AS VARCHAR(10));
		
		RAISERROR('Total number of weighting factors to calculate: %s ', 0, 1, @sTotalLoops) WITH NOWAIT;

		DECLARE @sLoopCounter VARCHAR(10);

		--Start looping through #InfillFactors
		WHILE @LoopCounter <= @TotalLoops
		BEGIN
			
			SELECT @PlayerPositionKey = PlayerPositionKey,
			@SeasonKey = SeasonKey,
			@GameweekKey = GameweekKey,
			@PredictionPointsAllWeighting = PredictionPointsAllWeighting,
			@PredictionPoints5Weighting = PredictionPoints5Weighting,
			@PredictionPoints10Weighting = PredictionPoints10Weighting
			FROM #InfillFactors
			WHERE Id = @LoopCounter;

			IF @Debug = 1
			BEGIN

				--SELECT @PlayerPositionKey AS PlayerPositionKey,
				--@SeasonKey AS SeasonKey,
				--@GameweekKey AS GameweekKey,
				--@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
				--@PredictionPoints5Weighting AS PredictionPoints5Weighting,
				--@PredictionPoints10Weighting AS PredictionPoints10Weighting;

				SELECT ' SELECT @PlayerPositionKey = PlayerPositionKey,
				@SeasonKey = SeasonKey,
				@GameweekKey = GameweekKey,
				@PredictionPointsAllWeighting = PredictionPointsAllWeighting,
				@PredictionPoints5Weighting = PredictionPoints5Weighting,
				@PredictionPoints10Weighting = PredictionPoints10Weighting
				FROM #InfillFactors
				WHERE Id = ' + CAST(@LoopCounter AS VARCHAR(5)) + ';';

				SELECT 'SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(2)) + ' AND GameweekKey = ' + CAST(@GameweekKey AS VARCHAR(2)) + ';'

			END

			SELECT @Gameweek = Id FROM #Gameweeks WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;
			SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;
			SELECT @SeasonEnd = SeasonKey, @GameweekEnd = GameweekKey FROM #Gameweeks WHERE Id = @Gameweek + (@Gameweeks - 1);
			
			--SET @CurrentTime = CONVERT(VARCHAR(20),GETDATE(),120);
			IF @LoopCounter < 1000
				SELECT @sLoopCounter = CAST(@LoopCounter AS VARCHAR(10));
			ELSE
				SELECT @sLoopCounter = CAST(@LoopCounter/1000 AS VARCHAR(10)) + ',' + RIGHT('000' + CAST(@LoopCounter - ((@LoopCounter/1000) * 1000) AS VARCHAR(10)), 3);

			RAISERROR('PlayerPositionKey: %d SeasonKey: %d GameweekKey: %d PredictionPointsAllWeighting: %d PredictionPoints5Weighting: %d PredictionPoints10Weighting: %d (%s/%s) (%s PERCENT)', 0, 1, @PlayerPositionKey, @SeasonKey, @GameweekKey, @PredictionPointsAllWeighting, @PredictionPoints5Weighting, @PredictionPoints10Weighting, @sLoopCounter, @sTotalLoops, @ProgressPercentageString) WITH NOWAIT;

			IF @Debug = 1
			BEGIN

				SELECT @PlayerPositionKey AS PlayerPositionKey,
				@SeasonKey AS SeasonKey,
				@GameweekKey AS GameweekKey,
				@SeasonEnd AS SeasonEnd,
				@GameweekEnd AS GameweekEnd,
				@Gameweek AS Gameweek, 
				@Gameweeks AS Gameweeks,
				@GameweekStartDate AS GameweekStartDate,
				@MinutesLimit AS MinutesLimit,
				@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
				@PredictionPoints5Weighting AS PredictionPoints5Weighting,
				@PredictionPoints10Weighting AS PredictionPoints10Weighting;

				SELECT 'EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing
				@SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + ',
				@Gameweeks = ' + CAST(@Gameweeks AS VARCHAR(3)) + ',
				@GameweekStart = ' + CAST(@GameweekKey AS VARCHAR(3)) + ',
				@GameweekStartDate = ''' + ISNULL(CAST(@GameweekStartDate AS VARCHAR(20)),'') + ''',
				@SeasonEnd = ' + CAST(@SeasonEnd AS VARCHAR(3)) + ',
				@GameweekEnd = ' + CAST(@GameweekEnd AS VARCHAR(3)) + ',
				@PlayerPositionKey = ' + CAST(@PlayerPositionKey AS VARCHAR(3)) + ',
				@MinutesLimit = ' + CAST(@MinutesLimit AS VARCHAR(3)) + ',
				@PredictionPointsAllWeighting = ' + CAST(@PredictionPointsAllWeighting AS VARCHAR(3)) + ',
				@PredictionPoints5Weighting = ' + CAST(@PredictionPoints5Weighting AS VARCHAR(3)) + ',
				@PredictionPoints10Weighting = ' + CAST(@PredictionPoints10Weighting AS VARCHAR(3)) + ',
				@NumOfRowsToReturn = 200;';

			END
			ELSE
			BEGIN
							
				EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing
				@SeasonKey = @SeasonKey,
				@Gameweeks = @Gameweeks,
				@GameweekStart = @GameweekKey,
				@GameweekStartDate = @GameweekStartDate,
				@SeasonEnd = @SeasonEnd,
				@GameweekEnd = @GameweekEnd,
				@PlayerPositionKey = @PlayerPositionKey,
				@MinutesLimit = @MinutesLimit,
				@PredictionPointsAllWeighting = @PredictionPointsAllWeighting,
				@PredictionPoints5Weighting = @PredictionPoints5Weighting,
				@PredictionPoints10Weighting = @PredictionPoints10Weighting,
				@NumOfRowsToReturn = 200;

				INSERT INTO dbo.WeightingFactorsAnalysis
				([SeasonKey]
				,[GameweekStartKey]
				,[Gameweeks]
				,[PlayerPositionKey]
				,[PredictionPointsAllWeighting]
				,[PredictionPoints5Weighting]
				,[PredictionPoints10Weighting]
				,[PlayerKey]
				,[PlayerName]
				,[Cost]
				,[PlayerPosition]
				,[TeamName]
				,[TotalPlayerGames]
				,[TotalPlayerMinutes]
				,[CurrentPoints]
				,[PredictedPointsAll]
				,[PredictedPoints5]
				,[PredictedPoints10]
				,[OverallPPGPredictionPoints]
				,[OverallTeamPPGPredictionPoints]
				,[OverallDifficultyPPGPredictionPoints]
				,[OverallFractionOfMinutesPlayed]
				,[Prev5FractionOfMinutesPlayed]
				,[StartingProbability]
				,[TotalGames]
				,[TeamTotalGames]
				,[DifficultyTotalGames]
				,[PredictedPointsPath]
				,[PredictedPoints]
				,[PredictedPointsWeighted]
				,[ChanceOfPlayingNextRound])
				SELECT *
				FROM #FinalPrediction;

				IF @DebugExec = 1
				BEGIN

					SELECT *
					FROM #FinalPrediction;

				END
							
				DELETE FROM #FinalPrediction;

			END

			SET @LoopCounter = @LoopCounter + 1;
			SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
			SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));

		END
		RAISERROR('Completed!!!', 0, 1, @ProgressPercentageString) WITH NOWAIT;

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