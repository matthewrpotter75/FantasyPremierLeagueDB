CREATE PROCEDURE dbo.AnalyzingWeightingFactors
(
	--DECLARE
	@Gameweeks INT = 5,
	@MinutesLimit INT = 30,
	@MaxPredictionPointsAllWeighting INT = 2,
	@MaxPredictionPoints5Weighting INT = 2,
	@MaxPredictionPoints10Weighting INT = 2,
	@Increment INT = 0,
	@IsResume BIT = 0,
	@ResumePlayerPositionKey INT = NULL,
	@ResumeGameweek INT = NULL,
	@ResumePredictionPointsAllWeighting INT = NULL,
	@ResumePredictionPoints5Weighting INT = NULL,
	@ResumePredictionPoints10Weighting INT = NULL,
	@IsExtend BIT = 0,
	@IsRestart BIT = 0,
	@Debug BIT = 0,
	@DebugExec BIT = 0
)
AS
BEGIN

	BEGIN TRY

		SET NOCOUNT ON;

		IF @IsRestart = 1
		BEGIN
			IF OBJECT_ID('dbo.WeightingFactorsAnalysis') IS NOT NULL
				TRUNCATE TABLE dbo.WeightingFactorsAnalysis;
		END

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

		IF OBJECT_ID('tempdb..#Gameweeks') IS NOT NULL
			DROP TABLE #Gameweeks;

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
		WHERE GameweekRank > @Gameweeks
		ORDER BY SeasonKey, GameweekKey;

		IF @Debug = 1
		BEGIN

			SELECT *
			FROM #Gameweeks
			ORDER BY SeasonKey, GameweekKey;

		END

		SELECT @MaxGameweek = MAX(Id) FROM #Gameweeks;
		SELECT @GameweekCount = COUNT(1) FROM #Gameweeks;
		SELECT @TotalLoops = (4.00 * @GameweekCount * (@MaxPredictionPointsAllWeighting/@Increment) * (@MaxPredictionPoints5Weighting/@Increment) * (@MaxPredictionPoints10Weighting/@Increment));

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

		SELECT @Gameweeks AS Gameweeks, @MaxGameweek AS TotalGameweeks, @MaxPredictionPointsAllWeighting AS MaxPredictionPointsAllWeighting, @MaxPredictionPoints5Weighting AS MaxPredictionPoints5Weighting, @MaxPredictionPoints10Weighting AS MaxPredictionPoints10Weighting, @TotalLoops AS TotalLoops;

		SET @PlayerPositionKey = 1;
		SET @Gameweek = 1;
		SET @LoopCounter = 1;

		IF @IsResume = 1 OR @IsExtend = 1
		BEGIN

			IF @ResumePredictionPointsAllWeighting IS NOT NULL
			BEGIN

				SET @PlayerPositionKey = @ResumePlayerPositionKey;
				SET @Gameweek = @ResumeGameweek;
				SET @PredictionPointsAllWeighting = @ResumePredictionPointsAllWeighting;
				SET @PredictionPoints5Weighting = @ResumePredictionPoints5Weighting;
				SET @PredictionPoints10Weighting = @ResumePredictionPoints10Weighting;

			END
			ELSE
			BEGIN

				SELECT @MaxWeightingFactorsAnalysisKey = MAX(WeightingFactorsAnalysisKey) FROM dbo.WeightingFactorsAnalysis;

				SELECT @PlayerPositionKey = PlayerPositionKey,
				@SeasonKey = SeasonKey,
				@GameweekKey = GameweekStartKey,
				@PredictionPointsAllWeighting = PredictionPointsAllWeighting,
				@PredictionPoints5Weighting = PredictionPoints5Weighting,
				@PredictionPoints10Weighting = PredictionPoints10Weighting
				FROM dbo.WeightingFactorsAnalysis
				WHERE WeightingFactorsAnalysisKey = @MaxWeightingFactorsAnalysisKey;

				SELECT @Gameweek = Id FROM #Gameweeks WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;

				SELECT 'Current max values';

				SELECT @IsResume AS IsResume,
				@IsExtend AS IsExtend,
				@PlayerPositionKey AS PlayerPositionKey,
				@SeasonKey AS SeasonKey,
				@GameweekKey AS GameweekKey,
				@Gameweek AS Gameweek,
				@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
				@PredictionPoints5Weighting AS PredictionPoints5Weighting,
				@PredictionPoints10Weighting AS PredictionPoints10Weighting;

				SELECT @Gameweek = @Gameweek + 1;
				SELECT @SeasonKey = SeasonKey, @GameweekKey = GameweekKey FROM #Gameweeks WHERE Id = @Gameweek;

				--Calculate what the next combination to be run to pass into the looping code
				IF @PredictionPoints10Weighting = @MaxPredictionPoints10Weighting
				BEGIN

					SET @PredictionPoints10Weighting = 1;

					IF @PredictionPoints5Weighting = @MaxPredictionPoints5Weighting
					BEGIN

						SET @PredictionPoints5Weighting = 1;

						IF @PredictionPointsAllWeighting = @MaxPredictionPointsAllWeighting
						BEGIN

							SET @PredictionPointsAllWeighting = 1;

							IF @Gameweek = @MaxGameweek
							BEGIN

								IF @PlayerPositionKey = 4
								BEGIN

									PRINT 'Processing has already completed!!!';

								END
								ELSE 
								BEGIN

									SET @PlayerPositionKey = @PlayerPositionKey + 1;

								END

							END

						END
						ELSE
						BEGIN

							SET @PredictionPointsAllWeighting = @PredictionPointsAllWeighting + 1;

						END

					END
					ELSE
					BEGIN

						SET @PredictionPoints5Weighting = @PredictionPoints5Weighting + 1;

					END

				END
				ELSE
				BEGIN

					SET @PredictionPoints10Weighting = @PredictionPoints10Weighting + 1;

				END

				--SELECT @Gameweek = Id FROM #Gameweeks WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;

			END

		END

		IF @IsExtend = 1
		BEGIN

			SET @PlayerPositionKey = 1;
			SET @Gameweek = 1;

			SELECT @PredictionPointsAllWeighting = MAX(PredictionPointsAllWeighting)
			FROM dbo.WeightingFactorsAnalysis
			WHERE PredictionPointsAllWeighting % @Increment = 0

			SET @PredictionPointsAllWeighting = @PredictionPointsAllWeighting + @Increment;
			SET @PredictionPoints5Weighting = @PredictionPointsAllWeighting;
			SET @PredictionPoints10Weighting = @PredictionPointsAllWeighting;

		END

		IF @IsResume = 1
		BEGIN

			SET @LoopCounter = 
					(SELECT COUNT(*)
					 FROM
						(
							SELECT PlayerPositionKey, SeasonKey, GameweekStartKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting
							FROM dbo.WeightingFactorsAnalysis
							WHERE PredictionPointsAllWeighting % @Increment = 0
							GROUP BY PlayerPositionKey, SeasonKey, GameweekStartKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting
						 ) t
					);

			SELECT @LoopCounter = @LoopCounter/@Increment;

		END

		SELECT 'Initial Loop Conditions';

		SELECT @IsResume AS IsResume,
		@IsExtend AS IsExtend,
		@PlayerPositionKey AS PlayerPositionKey,
		@SeasonKey AS SeasonKey,
		@GameweekKey AS GameweekKey,
		@Gameweek AS Gameweek,
		@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
		@PredictionPoints5Weighting AS PredictionPoints5Weighting,
		@PredictionPoints10Weighting AS PredictionPoints10Weighting;

		SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
		SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));

		DECLARE @sTotalLoops VARCHAR(10);

		IF @TotalLoops > 1000
			SELECT @sTotalLoops = CAST(@TotalLoops/1000 AS VARCHAR(10)) + ',' + RIGHT('000' + CAST(@TotalLoops - ((@TotalLoops/1000) * 1000) AS VARCHAR(10)), 3);
		ELSE
			SELECT @sTotalLoops = CAST(@TotalLoops AS VARCHAR(10));
		
		RAISERROR('Total number of weighting factors to calculate: %s ', 0, 1, @sTotalLoops) WITH NOWAIT;

		DECLARE @sLoopCounter VARCHAR(10);

		SET @PredictionPointsAllWeighting = @Increment;
		SET @PredictionPoints5Weighting = @Increment;
		SET @PredictionPoints10Weighting = @Increment;

		--Start looping through PlayerPositions, Gameweeks, and all the combinations of the 3 weighting factors
		WHILE @PlayerPositionKey <= 4
		BEGIN

			SELECT @PlayerPosition = PlayerPositionShort FROM dbo.DimPlayerPosition WHERE PlayerPositionKey = @PlayerPositionKey
			RAISERROR('PlayerPosition: %s', 0, 1, @PlayerPosition) WITH NOWAIT;

			WHILE @Gameweek <= @MaxGameweek
			BEGIN

				IF @IsResume = 0 AND @IsExtend = 0
				BEGIN

					SET @PredictionPointsAllWeighting = @Increment;
					SET @PredictionPoints5Weighting = @Increment;
					SET @PredictionPoints10Weighting = @Increment;

				END

				IF @Debug = 1
					SELECT 'SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(2)) + ' AND GameweekKey = ' + CAST(@GameweekKey AS VARCHAR(2)) + ';'

				SELECT @GameweekKey = GameweekKey, @SeasonKey = SeasonKey FROM #Gameweeks WHERE Id = @Gameweek;
				SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;
				SELECT @SeasonEnd = SeasonKey, @GameweekEnd = GameweekKey FROM #Gameweeks WHERE Id = @Gameweek + (@Gameweeks - 1);
			
				--RAISERROR('SeasonKey: %d GameweekKey: %d ( %d out of %d )', 0, 1, @SeasonKey, @GameweekKey, @LoopCounter, @TotalLoops) WITH NOWAIT;
				SET @CurrentTime = CONVERT(VARCHAR(20),GETDATE(),120);
				RAISERROR('SeasonKey: %d GameweekKey: %d (%s)', 0, 1, @SeasonKey, @GameweekKey, @CurrentTime) WITH NOWAIT;

				WHILE @PredictionPointsAllWeighting <= @MaxPredictionPointsAllWeighting
				BEGIN

					WHILE @PredictionPoints5Weighting <= @MaxPredictionPoints5Weighting
					BEGIN

						WHILE @PredictionPoints10Weighting <= @MaxPredictionPoints10Weighting
						BEGIN

							IF @LoopCounter < 1000
								SELECT @sLoopCounter = CAST(@LoopCounter AS VARCHAR(10));
							ELSE
								SELECT @sLoopCounter = CAST(@LoopCounter/1000 AS VARCHAR(10)) + ',' + RIGHT('000' + CAST(@LoopCounter - ((@LoopCounter/1000) * 1000) AS VARCHAR(10)), 3);

							RAISERROR('PredictionPointsAllWeighting: %d PredictionPoints5Weighting: %d PredictionPoints10Weighting: %d (%s/%s) (%s)', 0, 1, @PredictionPointsAllWeighting, @PredictionPoints5Weighting, @PredictionPoints10Weighting, @sLoopCounter, @sTotalLoops, @ProgressPercentageString) WITH NOWAIT;

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

							END
							
							IF @DebugExec = 1
							BEGIN

								SELECT *
								FROM #FinalPrediction;

							END
							
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
							
							DELETE FROM #FinalPrediction;		

							SET @LoopCounter = @LoopCounter + 1;
							SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
							SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));
							SET @PredictionPoints10Weighting = @PredictionPoints10Weighting + @Increment;

						END

						SET @PredictionPoints5Weighting = @PredictionPoints5Weighting + @Increment;
						SET @PredictionPoints10Weighting = @Increment;

					END

					SET @PredictionPointsAllWeighting = @PredictionPointsAllWeighting + @Increment;
					SET @PredictionPoints5Weighting = @Increment;
					SET @PredictionPoints10Weighting = @Increment;

				END

				SET @Gameweek = @Gameweek + 1;
				SET @PredictionPointsAllWeighting = @Increment;
				SET @PredictionPoints5Weighting = @Increment;
				SET @PredictionPoints10Weighting = @Increment;

			END

			SET @PlayerPositionKey = @PlayerPositionKey + 1;
			SET @Gameweek = 1;
			SET @PredictionPointsAllWeighting = @Increment;
			SET @PredictionPoints5Weighting = @Increment;
			SET @PredictionPoints10Weighting = @Increment;

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