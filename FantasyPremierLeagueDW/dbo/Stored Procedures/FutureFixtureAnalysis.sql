CREATE PROCEDURE dbo.FutureFixtureAnalysis
(
	--DECLARE
	@SeasonKey INT = NULL,
	@Gameweeks INT = 5,
	@PlayerPositionKey INT = 2,
	@MinutesLimit INT = 30,
	@Debug BIT = 0,
	@TimerDebug BIT = 0,
	@PlayerKey INT = NULL,
	@GameweekStart INT = NULL
)
AS
BEGIN

	BEGIN TRY

		SET NOCOUNT ON;

		--TODO: 
		--Limit PPG calculation to where player hasn't moved clubs or has moved to equal club or better club

		DECLARE @SeasonEnd INT, @GameweekEnd INT, @GameweekStartDate DATE, @CurrentSeasonKey INT, @CurrentGameweekKey INT, @AnalysisDeadlineTime SMALLDATETIME;

		IF @SeasonKey IS NULL
		BEGIN
			SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
		END

		SELECT @CurrentSeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
		SELECT TOP (1)  @CurrentGameweekKey = GameweekKey FROM dbo.DimGameweek WHERE SeasonKey = @CurrentSeasonKey AND GETDATE() < DeadlineTime ORDER BY DeadlineTime;
		SELECT @AnalysisDeadlineTime = DeadlineTime FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekStart;

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

		IF OBJECT_ID('tempdb..#ActualPlayerPoints') IS NOT NULL
			DROP TABLE #ActualPlayerPoints;

		IF OBJECT_ID('tempdb..#FinalPrediction') IS NOT NULL
			DROP TABLE #FinalPrediction;

		--Create temp table with actual points over the prediction period
		SELECT ph.PlayerKey,
		pa.PlayerPositionKey,
		SUM(ph.TotalPoints) AS ActualPoints,
		COUNT(ph.PlayerKey) AS ActualGames,
		SUM(ph.[Minutes]) AS ActualPlayerMinutes
		INTO #ActualPlayerPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		WHERE pa.PlayerPositionKey = @PlayerPositionKey
		AND ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		GROUP BY ph.PlayerKey, pa.PlayerPositionKey;

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
			
			SELECT 'EXEC dbo.FutureFixturePlayerPointsPredictionsProcessing ' +
			CAST(@SeasonKey AS VARCHAR(3)) + ',' +
			CAST(@Gameweeks AS VARCHAR(3)) + ',' +
			CAST(@PlayerPositionKey AS VARCHAR(3)) + ',' +
			CAST(@MinutesLimit AS VARCHAR(3)) + ',' +
			CAST(@Debug AS VARCHAR(3)) + ',' +
			CAST(@TimerDebug AS VARCHAR(3)) + ',' +
			ISNULL(CAST(@PlayerKey AS VARCHAR(4)),'NULL') + ',' +
			CAST(@GameweekStart AS VARCHAR(3)) + ',' +
			CAST(@GameweekEnd AS VARCHAR(3)) + ',' +
			CAST(@SeasonEnd AS VARCHAR(3)) + ',
			''' + ISNULL(CAST(@GameweekStartDate AS VARCHAR(24)),'NULL') + '''';

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
		
		SELECT 
			f.SeasonKey,
			f.GameweekStartKey,
			f.Gameweeks,
			f.PlayerPositionKey,
			f.PredictionPointsAllWeighting,
			f.PredictionPoints5Weighting,
			f.PredictionPoints10Weighting,
			f.PlayerKey,
			f.PlayerName,
			f.Cost,
			f.PlayerPosition,
			f.TeamName,
			f.TotalPlayerGames,
			f.TotalPlayerMinutes,
			f.CurrentPoints,
			f.PredictedPointsAll,
			f.PredictedPoints5,
			f.PredictedPoints10,
			f.OverallPPGPredictionPoints,
			f.OverallTeamPPGPredictionPoints,
			f.OverallDifficultyPPGPredictionPoints,
			f.OverallFractionOfMinutesPlayed,
			f.Prev5FractionOfMinutesPlayed,
			f.StartingProbability,
			f.TotalGames,
			f.TeamTotalGames,
			f.DifficultyTotalGames,
			f.PredictedPointsPath,
			f.PredictedPoints,
			f.PredictedPointsWeighted,
			app.ActualPoints,
			app.ActualGames,
			app.ActualPlayerMinutes,
			ABS(f.PredictedPointsWeighted - app.ActualPoints) AS ABSDiffPrediction,
			f.PredictedPointsWeighted - app.ActualPoints AS DiffPrediction,
			f.ChanceOfPlayingNextRound
		FROM #FinalPrediction f
		INNER JOIN #ActualPlayerPoints app
		ON f.PlayerKey = app.PlayerKey
		--ORDER BY f.OverallPredictionWeighted DESC;
		ORDER BY ISNULL(ABS(f.PredictedPointsWeighted - app.ActualPoints), f.PredictedPointsWeighted);

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