CREATE PROCEDURE dbo.AnalyzingWeightingFactors
(
	--DECLARE
	@Gameweeks INT = 5,
	@MinutesLimit INT = 30,
	@MaxPredictionPointsAllWeighting INT = 2,
	@MaxPredictionPoints5Weighting INT = 2,
	@MaxPredictionPoints10Weighting INT = 2,
	@Increment INT = 1,
	@IsResume BIT = 0,
	@ResumePlayerPositionKey INT = NULL,
	@ResumeGameweek INT = NULL,
	@ResumePredictionPointsAllWeighting INT = NULL,
	@ResumePredictionPoints5Weighting INT = NULL,
	@ResumePredictionPoints10Weighting INT = NULL,
	@IsExtend BIT = 0,
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
		@GameweekEnd INT,
		@MaxGameweek INT, 
		@GameweekStartDate DATE, 
		@PredictionPointsAllWeighting INT, 
		@PredictionPoints5Weighting INT, 
		@PredictionPoints10Weighting INT,
		@TotalLoops BIGINT,
		@LoopCounter BIGINT,
		@ProgressPercentage DECIMAL(5,1),
		@ProgressPercentageString VARCHAR(10),
		@CurrentTime VARCHAR(20);

		
		IF @IsResume = 0
		BEGIN
			IF OBJECT_ID('dbo.WeightingFactorsAnalysis') IS NOT NULL
				TRUNCATE TABLE dbo.WeightingFactorsAnalysis;
		END

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

		SELECT @GameweekCount = COUNT(1) FROM #Gameweeks;
		SELECT @TotalLoops = (4.00 * @GameweekCount * @MaxPredictionPointsAllWeighting * @MaxPredictionPoints5Weighting * @MaxPredictionPoints10Weighting)/@Increment;

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

		IF @IsResume = 1 OR @IsExtend = 1
		BEGIN

			IF @PredictionPointsAllWeighting IS NOT NULL
			BEGIN

				SET @PlayerPositionKey = @ResumePlayerPositionKey;
				SET @Gameweek = @ResumeGameweek;
				SET @PredictionPointsAllWeighting = @ResumePredictionPointsAllWeighting;
				SET @PredictionPoints5Weighting = @ResumePredictionPoints5Weighting;
				SET @PredictionPoints10Weighting = @ResumePredictionPoints10Weighting;

			END
			ELSE
			BEGIN

				;WITH MaxPlayerPosition AS
				(
					SELECT MAX(PlayerPositionKey) AS MaxPlayerPositionKey
					FROM [FantasyPremierLeagueDW].[dbo].[WeightingFactorsAnalysis] WITH (NOLOCK)
				),
				MaxSeasonKey AS
				(	
					SELECT MAX(SeasonKey) AS MaxSeasonKey
					FROM [FantasyPremierLeagueDW].[dbo].[WeightingFactorsAnalysis] WITH (NOLOCK)
					WHERE PlayerPositionKey IN
					(
						SELECT MaxPlayerPositionKey
						FROM MaxPlayerPosition
					)
				),
				MaxGameweekKey AS
				(
					SELECT MAX(GameweekStartKey) AS MaxGameweekKey
					FROM [FantasyPremierLeagueDW].[dbo].[WeightingFactorsAnalysis] WITH (NOLOCK)
					WHERE SeasonKey IN
					(
						SELECT MaxSeasonKey
						FROM MaxSeasonKey
					)
					AND PlayerPositionKey IN
					(
						SELECT MaxPlayerPositionKey
						FROM MaxPlayerPosition
					)
				),
				MaxPredictionPointsAllWeighting AS
				(
					SELECT MAX(PredictionPointsAllWeighting) AS MaxPredictionPointsAllWeighting
					FROM [FantasyPremierLeagueDW].[dbo].[WeightingFactorsAnalysis] WITH (NOLOCK)
					WHERE SeasonKey IN
					(
						SELECT MaxSeasonKey
						FROM MaxSeasonKey
					)
					AND GameweekStartKey IN
					(
						SELECT MaxGameweekKey
						FROM MaxGameweekKey
					)
					AND PlayerPositionKey IN
					(
						SELECT MaxPlayerPositionKey
						FROM MaxPlayerPosition
					)
				),
				MaxPredictionPoints5Weighting AS
				(
					SELECT MAX(PredictionPoints5Weighting) AS MaxPredictionPoints5Weighting
					FROM [FantasyPremierLeagueDW].[dbo].[WeightingFactorsAnalysis] WITH (NOLOCK)
					WHERE PredictionPointsAllWeighting IN
					(
						SELECT MaxPredictionPointsAllWeighting
						FROM MaxPredictionPointsAllWeighting
					)
					AND SeasonKey IN
					(
						SELECT MaxSeasonKey
						FROM MaxSeasonKey
					)
					AND GameweekStartKey IN
					(
						SELECT MaxGameweekKey
						FROM MaxGameweekKey
					)
					AND PlayerPositionKey IN
					(
						SELECT MaxPlayerPositionKey
						FROM MaxPlayerPosition
					)
				),
				MaxPredictionPoints10Weighting AS
				(
					SELECT MAX(PredictionPoints10Weighting) AS MaxPredictionPoints10Weighting
					FROM [FantasyPremierLeagueDW].[dbo].[WeightingFactorsAnalysis] WITH (NOLOCK)
					WHERE PredictionPoints5Weighting IN
					(
						SELECT MaxPredictionPoints5Weighting
						FROM MaxPredictionPoints5Weighting
					)
					AND PredictionPointsAllWeighting IN
					(
						SELECT MaxPredictionPointsAllWeighting
						FROM MaxPredictionPointsAllWeighting
					)
					AND SeasonKey IN
					(
						SELECT MaxSeasonKey
						FROM MaxSeasonKey
					)
					AND GameweekStartKey IN
					(
						SELECT MaxGameweekKey
						FROM MaxGameweekKey
					)
					AND PlayerPositionKey IN
					(
						SELECT MaxPlayerPositionKey
						FROM MaxPlayerPosition
					)
				)
				SELECT 'MaxPlayerPositionKey' AS [Key], MaxPlayerPositionKey AS MaxKeyValue
				INTO #AllMaxKeys
				FROM MaxPlayerPosition

				UNION ALL

				SELECT 'MaxSeasonKey' AS [Key], MaxSeasonKey
				FROM MaxSeasonKey

				UNION ALL

				SELECT 'MaxGameweekKey' AS [Key], MaxGameweekKey
				FROM MaxGameweekKey

				UNION ALL

				SELECT 'MaxPredictionPointsAllWeighting' AS [Key], MaxPredictionPointsAllWeighting
				FROM MaxPredictionPointsAllWeighting

				UNION ALL

				SELECT 'MaxPredictionPoints5Weighting' AS [Key], MaxPredictionPoints5Weighting
				FROM MaxPredictionPoints5Weighting

				UNION ALL

				SELECT 'MaxPredictionPoints10Weighting' AS [Key], MaxPredictionPoints10Weighting
				FROM MaxPredictionPoints10Weighting;

				SELECT @PlayerPositionKey = MaxKeyValue FROM #AllMaxKeys WHERE [Key] = 'MaxPlayerPositionKey';
				SELECT @SeasonKey = MaxKeyValue FROM #AllMaxKeys WHERE [Key] = 'MaxSeasonKey';
				SELECT @GameweekKey = MaxKeyValue FROM #AllMaxKeys WHERE [Key] = 'MaxGameweekKey';
				SELECT @PredictionPointsAllWeighting = MaxKeyValue FROM #AllMaxKeys WHERE [Key] = 'MaxPredictionPointsAllWeighting';
				SELECT @PredictionPoints5Weighting = MaxKeyValue FROM #AllMaxKeys WHERE [Key] = 'MaxPredictionPoints5Weighting';
				SELECT @PredictionPoints10Weighting = MaxKeyValue FROM #AllMaxKeys WHERE [Key] = 'MaxPredictionPoints10Weighting';

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

								SET @Gameweek = 1;

								IF @PlayerPositionKey = 4
								BEGIN

									PRINT 'Processing has already completed!!!';

								END
								ELSE
								BEGIN

									SET @PlayerPositionKey = @PlayerPositionKey + 1;

								END

							END
							ELSE
							BEGIN

								SET @Gameweek = @Gameweek + 1;

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

				SELECT @Gameweek = Id FROM #Gameweeks WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekKey;

			END

		END

		IF @IsExtend = 1
		BEGIN

			SET @PlayerPositionKey = 1;
			SET @Gameweek = 1;
			SET @PredictionPointsAllWeighting = @PredictionPoints5Weighting + 1;
			SET @PredictionPoints5Weighting = 1;
			SET @PredictionPoints10Weighting = 1;

		END

		IF @Debug = 1
		BEGIN

				SELECT @IsResume AS IsResume,
				@PlayerPositionKey AS PlayerPositionKey,
				@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
				@PredictionPoints5Weighting AS PredictionPoints5Weighting,
				@PredictionPoints10Weighting AS PredictionPoints10Weighting,
				@SeasonKey AS SeasonKey,
				@GameweekKey AS GameweekKey,
				@Gameweek AS Gameweek;

		END

		--Start looping through PlayerPositions, Gameweeks, and all the combinations of the 3 weighting factors
		WHILE @PlayerPositionKey <= 4
		BEGIN

			SELECT @PlayerPosition = SingularNameShort FROM dbo.DimPlayerPosition WHERE PlayerPositionKey = @PlayerPositionKey
			RAISERROR('PlayerPosition: %s', 0, 1, @PlayerPosition) WITH NOWAIT;

			WHILE @Gameweek <= @MaxGameweek
			BEGIN

				IF @IsResume = 0 AND @IsExtend = 0
				BEGIN

					SET @PredictionPointsAllWeighting = 1;
					SET @PredictionPoints5Weighting = 1;
					SET @PredictionPoints10Weighting = 1;

				END

				IF @Debug = 1
					SELECT 'SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(2)) + ' AND GameweekKey = ' + CAST(@GameweekKey AS VARCHAR(2)) + ';'

				SELECT @GameweekKey = GameweekKey, @SeasonKey = SeasonKey FROM #Gameweeks WHERE Id = @GameweekKey;
				SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @Gameweek;
				SELECT @GameweekEnd = (SELECT GameweekKey FROM #Gameweeks WHERE Id = @Gameweek + (@Increment - 1));
				--what happens if gameweek end is in the next season? - need to change FutureFixturePlayerPointsPredictionsProcessing
			
				--RAISERROR('SeasonKey: %d GameweekKey: %d ( %d out of %d )', 0, 1, @SeasonKey, @GameweekKey, @LoopCounter, @TotalLoops) WITH NOWAIT;
				SET @CurrentTime = CONVERT(VARCHAR(20),GETDATE(),120);
				RAISERROR('SeasonKey: %d GameweekKey: %d ( %s )', 0, 1, @SeasonKey, @GameweekKey, @CurrentTime) WITH NOWAIT;

				WHILE @PredictionPointsAllWeighting <= @MaxPredictionPointsAllWeighting
				BEGIN

					WHILE @PredictionPoints5Weighting <= @MaxPredictionPoints5Weighting
					BEGIN

						WHILE @PredictionPoints10Weighting <= @MaxPredictionPoints10Weighting
						BEGIN

							RAISERROR('PredictionPointsAllWeighting: %d PredictionPoints5Weighting: %d PredictionPoints10Weighting: %d ( %s )', 0, 1, @PredictionPointsAllWeighting, @PredictionPoints5Weighting, @PredictionPoints10Weighting, @ProgressPercentageString) WITH NOWAIT;

							IF @Debug = 1
							BEGIN

								SELECT @SeasonKey AS SeasonKey, 
								@Gameweek AS Gameweek, 
								@Gameweeks AS Gameweeks, 
								@GameweekStartDate AS GameweekStartDate, 
								@GameweekEnd AS GameweekEnd, 
								@PlayerPositionKey AS PlayerPositionKey, 
								@MinutesLimit AS MinutesLimit, 
								@PredictionPointsAllWeighting AS PredictionPointsAllWeighting, 
								@PredictionPoints5Weighting AS PredictionPoints5Weighting,
								@PredictionPoints10Weighting AS PredictionPoints10Weighting;

							END

							IF @Debug = 1
							BEGIN

								SELECT @SeasonKey AS SeasonKey,
								@Gameweeks AS Gameweeks,
								@GameweekKey AS GameweekKey,
								@GameweekStartDate AS GameweekStartDate,
								@GameweekEnd AS GameweekEnd,
								@PlayerPositionKey AS PlayerPositionKey,
								@MinutesLimit AS MinutesLimit,
								@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
								@PredictionPoints5Weighting AS PredictionPoints5Weighting,
								@PredictionPoints10Weighting AS PredictionPoints10Weighting;

								SELECT 'EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing
								@SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + ',
								@Gameweeks = ' + CAST(@Gameweeks AS VARCHAR(3)) + ',
								@GameweekStart = ' + CAST(@GameweekKey AS VARCHAR(3)) + ',
								@GameweekStartDate = ' + ISNULL(CAST(@GameweekStartDate AS VARCHAR(3)),'') + ',
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
							SELECT *
							FROM #FinalPrediction;
							
							DELETE FROM #FinalPrediction;		

							SET @LoopCounter = @LoopCounter + @Increment;
							SELECT @ProgressPercentage = CAST((@LoopCounter * 1.00/@TotalLoops) * 100 AS DECIMAL(5,1));
							SELECT @ProgressPercentageString = CAST(@ProgressPercentage AS VARCHAR(10));
							SET @PredictionPoints10Weighting = @PredictionPoints10Weighting + @Increment;

						END

						SET @PredictionPoints5Weighting = @PredictionPoints5Weighting + @Increment;
						SET @PredictionPoints10Weighting = 1;

					END

					SET @PredictionPointsAllWeighting = @PredictionPointsAllWeighting + @Increment;
					SET @PredictionPoints5Weighting = 1;
					SET @PredictionPoints10Weighting = 1;

				END

				SET @Gameweek = @Gameweek + 1;
				SET @PredictionPointsAllWeighting = 1;
				SET @PredictionPoints5Weighting = 1;
				SET @PredictionPoints10Weighting = 1;

			END

			SET @PlayerPositionKey = @PlayerPositionKey + 1;
			SET @Gameweek = 1;
			SET @PredictionPointsAllWeighting = 1;
			SET @PredictionPoints5Weighting = 1;
			SET @PredictionPoints10Weighting = 1;

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