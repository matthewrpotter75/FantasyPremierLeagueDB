CREATE PROCEDURE dbo.FutureFixturePlayerPointsPredictionsProcessing
(
	--DECLARE
	@SeasonKey INT,
	@Gameweeks INT = 5,
	@PlayerPositionKey INT = 2,
	@MinutesLimit INT = 30,
	@Debug BIT = 0,
	@TimerDebug BIT = 0,
	@PlayerKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@SeasonEnd INT,
	@GameweekStartDate SMALLDATETIME,
	@PredictionPointsAllWeighting INT = 5,
	@PredictionPoints5Weighting INT = 3,
	@PredictionPoints10Weighting INT = 2,
	@NumOfRowsToReturn INT = 200
)
AS
BEGIN
	
	BEGIN TRY

		SET NOCOUNT ON;

		DECLARE @time DATETIME;

		IF OBJECT_ID('tempdb..#Fixtures') IS NOT NULL
			DROP TABLE #Fixtures;

		IF OBJECT_ID('tempdb..#OverallPPG') IS NOT NULL
			DROP TABLE #OverallPPG;

		IF OBJECT_ID('tempdb..#OverallDifficultyPPG') IS NOT NULL
			DROP TABLE #OverallDifficultyPPG;

		IF OBJECT_ID('tempdb..#OverallTeamPPG') IS NOT NULL
			DROP TABLE #OverallTeamPPG;

		IF OBJECT_ID('tempdb..#PlayerPPG') IS NOT NULL
			DROP TABLE #PlayerPPG;

		IF OBJECT_ID('tempdb..#FixtureDifficulty') IS NOT NULL
			DROP TABLE #FixtureDifficulty;

		IF OBJECT_ID('tempdb..#PlayerPredictions') IS NOT NULL
			DROP TABLE #PlayerPredictions;

		IF OBJECT_ID('tempdb..#PlayingPercentagesPrevious5') IS NOT NULL
		DROP TABLE #PlayingPercentagesPrevious5;

		IF OBJECT_ID('tempdb..#PlayingPercentages') IS NOT NULL
			DROP TABLE #PlayingPercentages;

		DECLARE @CurrentSeasonKey INT, @CurrentGameweekKey INT, @AnalysisDeadlineTime SMALLDATETIME;

		SELECT @CurrentSeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
		SELECT TOP (1)  @CurrentGameweekKey = GameweekKey FROM dbo.DimGameweek WHERE SeasonKey = @CurrentSeasonKey AND GETDATE() < DeadlineTime ORDER BY DeadlineTime;
		SELECT @AnalysisDeadlineTime = DeadlineTime FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND GameweekKey = @GameweekStart;

		DECLARE @TotalPredictionPointsWeighting INT, @TotalExtraPredictionPointsWeighting INT;

		SET @TotalPredictionPointsWeighting = 100 + @PredictionPointsAllWeighting + @PredictionPoints5Weighting + @PredictionPoints10Weighting;
		SET @TotalExtraPredictionPointsWeighting = 200 + @PredictionPointsAllWeighting + @PredictionPoints5Weighting + @PredictionPoints10Weighting;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='Pre #Fixtures', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END
	
		--Get list of fixtures in the gameweeks to be analysed
		SELECT *
		INTO #Fixtures
		FROM dbo.fnGetFixtures(@SeasonKey, @PlayerPositionKey, @GameweekStart, @GameweekEnd, @SeasonEnd);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#Fixtures', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Create temp table with overall points per game
		SELECT *
		INTO #OverallPPG
		FROM dbo.fnGetOverallPPG(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#OverallPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Create temp table with overall points per game per team difficulty and opponent difficulty
		SELECT *
		INTO #OverallDifficultyPPG
		FROM dbo.fnGetOverallDifficultyPPG(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#OverallDifficultyPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END
	
		--Create temp table with overall points per game per team, opponent difficulty, and home/away for the position of the player
		SELECT *
		INTO #OverallTeamPPG
		FROM dbo.fnGetOverallTeamPPG(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#OverallTeamPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Aggregate to get one row per player (there will only be one value per row per difficulty so not really aggregation)
		;WITH AllPPG AS
		(
			SELECT ppg.PlayerKey, ppg.PlayerPositionKey, ppg.OpponentDifficulty, ppg.Games, ppg.PPG, ISNULL(prv5.PPG,0) AS PPG5, ISNULL(prv10.PPG,0) AS PPG10
			FROM dbo.PlayerPointsPerGame ppg
			LEFT JOIN dbo.PlayerPointsPerGamePrevious5 prv5
			ON ppg.PlayerKey = prv5.PlayerKey
			AND ppg.PlayerPositionKey = prv5.PlayerPositionKey
			AND ppg.OpponentDifficulty = prv5.OpponentDifficulty
			AND prv5.SeasonKey = @SeasonKey
			AND prv5.GameweekKey = (@GameweekStart - 1)
			LEFT JOIN dbo.PlayerPointsPerGamePrevious10 prv10
			ON prv5.SeasonKey = prv10.SeasonKey
			AND prv5.GameweekKey = prv10.GameweekKey
			AND prv5.PlayerKey = prv10.PlayerKey
			AND prv5.PlayerPositionKey = prv10.PlayerPositionKey
			AND prv5.OpponentDifficulty = prv10.OpponentDifficulty
			AND prv10.SeasonKey = @SeasonKey
			AND prv10.GameweekKey = (@GameweekStart - 1)
		)
		SELECT PlayerKey, 
		PlayerPositionKey,
		SUM(Games) AS TotalGames,
		SUM(CASE WHEN OpponentDifficulty = 1 THEN PPG ELSE 0 END) AS PPG_Diff1,
		SUM(CASE WHEN OpponentDifficulty = 1 THEN PPG5 ELSE 0 END) AS PPG5_Diff1,
		SUM(CASE WHEN OpponentDifficulty = 1 THEN PPG10 ELSE 0 END) AS PPG10_Diff1,
		SUM(CASE WHEN OpponentDifficulty = 2 THEN PPG ELSE 0 END) AS PPG_Diff2,
		SUM(CASE WHEN OpponentDifficulty = 2 THEN PPG5 ELSE 0 END) AS PPG5_Diff2,
		SUM(CASE WHEN OpponentDifficulty = 2 THEN PPG10 ELSE 0 END) AS PPG10_Diff2,
		SUM(CASE WHEN OpponentDifficulty = 3 THEN PPG ELSE 0 END) AS PPG_Diff3,
		SUM(CASE WHEN OpponentDifficulty = 3 THEN PPG5 ELSE 0 END) AS PPG5_Diff3,
		SUM(CASE WHEN OpponentDifficulty = 3 THEN PPG10 ELSE 0 END) AS PPG10_Diff3,
		SUM(CASE WHEN OpponentDifficulty = 4 THEN PPG ELSE 0 END) AS PPG_Diff4,
		SUM(CASE WHEN OpponentDifficulty = 4 THEN PPG5 ELSE 0 END) AS PPG5_Diff4,
		SUM(CASE WHEN OpponentDifficulty = 4 THEN PPG10 ELSE 0 END) AS PPG10_Diff4,
		SUM(CASE WHEN OpponentDifficulty = 5 THEN PPG ELSE 0 END) AS PPG_Diff5,
		SUM(CASE WHEN OpponentDifficulty = 5 THEN PPG5 ELSE 0 END) AS PPG5_Diff5,
		SUM(CASE WHEN OpponentDifficulty = 5 THEN PPG10 ELSE 0 END) AS PPG10_Diff5
		INTO #PlayerPPG
		FROM AllPPG
		GROUP BY PlayerKey, PlayerPositionKey
		ORDER BY PlayerKey, PlayerPositionKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#PlayerPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Get the difficulty of upcoming fixtures for each player
		CREATE TABLE #FixtureDifficulty 
		(
			PlayerKey INT NOT NULL,
			ChanceOfPlayingNextRound DECIMAL(5,2) NULL,
			Diff1GamesHome INT NOT NULL,
			Diff2GamesHome INT NOT NULL,
			Diff3GamesHome INT NOT NULL,
			Diff4GamesHome INT NOT NULL,
			Diff5GamesHome INT NOT NULL,
			Diff1GamesAway INT NOT NULL,
			Diff2GamesAway INT NOT NULL,
			Diff3GamesAway INT NOT NULL,
			Diff4GamesAway INT NOT NULL,
			Diff5GamesAway INT NOT NULL,
			TotalGames INT NOT NULL
		);
	
		--If player is injured, banned, or suspended then these games can be excluded from fixtures
		;WITH LatestPlayerNews AS
		(
			SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
			FROM
			(
				SELECT DISTINCT PlayerKey 
				FROM dbo.FactPlayerGameweekNews 
			) fpgn1
			CROSS APPLY
			(
				SELECT TOP (1) fpgn2.*
				FROM dbo.FactPlayerGameweekNews fpgn2
				WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
				ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
			) ca
			INNER JOIN dbo.FactPlayerGameweekStatus fpgs
			ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
		),
		PlayerChanceOfPlaying AS
		(
			SELECT p.PlayerKey, 
			pa.TeamKey,
			lpn.ChanceOfPlayingNextRound,
			CASE 
				WHEN ISNULL(lpn.News,'') <> '' AND CHARINDEX('Unknown return date', News) = 0 AND lpn.PlayerStatus IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(lpn.News), CHARINDEX(' ', REVERSE(lpn.News), CHARINDEX(' ',REVERSE(lpn.News))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
				ELSE @GameweekStartDate
			END AS StartDate
			FROM dbo.DimPlayer p
			INNER JOIN dbo.DimPlayerAttribute pa
			ON p.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			LEFT JOIN LatestPlayerNews lpn
			ON p.PlayerKey = lpn.PlayerKey
			WHERE pa.PlayerPositionKey = @PlayerPositionKey
		)
		INSERT INTO #FixtureDifficulty
		(PlayerKey, ChanceOfPlayingNextRound, Diff1GamesHome, Diff2GamesHome, Diff3GamesHome, Diff4GamesHome, Diff5GamesHome, Diff1GamesAway, Diff2GamesAway, Diff3GamesAway, Diff4GamesAway, Diff5GamesAway, TotalGames)
		SELECT p.PlayerKey,
		MIN(ch.ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
		SUM(CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff1GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff2GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff3GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff4GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff5GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff1GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff2GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff3GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff4GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff5GamesAway,
		COUNT(1) AS TotalGames
		FROM dbo.DimPlayer p
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN #Fixtures f
		ON pa.TeamKey = f.TeamKey
		LEFT JOIN PlayerChanceOfPlaying ch
		ON p.PlayerKey = ch.PlayerKey
		WHERE f.KickoffDate >= ch.StartDate OR f.KickoffDate IS NULL OR ch.StartDate IS NULL
		GROUP BY p.PlayerKey
		ORDER BY p.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#FixtureDifficulty', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Multiply the points per game for each difficulty level by the number of games for that difficulty
		SELECT ppg.PlayerKey,
		fd.ChanceOfPlayingNextRound,
		ppg.TotalGames,
		(fd.Diff1GamesHome + fd.Diff1GamesAway) * ppg.PPG_Diff1 AS Diff1Points,
		(fd.Diff2GamesHome + fd.Diff2GamesAway) * ppg.PPG_Diff2 AS Diff2Points,
		(fd.Diff3GamesHome + fd.Diff3GamesAway) * ppg.PPG_Diff3 AS Diff3Points,
		(fd.Diff4GamesHome + fd.Diff4GamesAway) * ppg.PPG_Diff4 AS Diff4Points,
		(fd.Diff5GamesHome + fd.Diff5GamesAway) * ppg.PPG_Diff5 AS Diff5Points,

		(fd.Diff1GamesHome + fd.Diff1GamesAway) * ppg.PPG5_Diff1 AS Diff1Points5,
		(fd.Diff2GamesHome + fd.Diff2GamesAway) * ppg.PPG5_Diff2 AS Diff2Points5,
		(fd.Diff3GamesHome + fd.Diff3GamesAway) * ppg.PPG5_Diff3 AS Diff3Points5,
		(fd.Diff4GamesHome + fd.Diff4GamesAway) * ppg.PPG5_Diff4 AS Diff4Points5,
		(fd.Diff5GamesHome + fd.Diff5GamesAway) * ppg.PPG5_Diff5 AS Diff5Points5,

		(fd.Diff1GamesHome + fd.Diff1GamesAway) * ppg.PPG10_Diff1 AS Diff1Points10,
		(fd.Diff2GamesHome + fd.Diff2GamesAway) * ppg.PPG10_Diff2 AS Diff2Points10,
		(fd.Diff3GamesHome + fd.Diff3GamesAway) * ppg.PPG10_Diff3 AS Diff3Points10,
		(fd.Diff4GamesHome + fd.Diff4GamesAway) * ppg.PPG10_Diff4 AS Diff4Points10,
		(fd.Diff5GamesHome + fd.Diff5GamesAway) * ppg.PPG10_Diff5 AS Diff5Points10
		INTO #PlayerPredictions
		FROM #PlayerPPG ppg
		INNER JOIN #FixtureDifficulty fd
		ON ppg.PlayerKey = fd.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#PlayerPredictions', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		;WITH Previous5Gameweeks AS
		(
			SELECT SeasonKey,
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekRank
			FROM dbo.DimGameweek
			WHERE DeadlineTime < @AnalysisDeadlineTime
		),
		TotalPlayerMinutes AS
		(
			SELECT ph.PlayerKey,
			pa.TeamKey,
			SUM(ph.[Minutes]) AS TotalPlayerMinutes,
			SUM(ph.TotalPoints) AS CurrentPoints
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND ph.SeasonKey = pa.SeasonKey
			INNER JOIN Previous5Gameweeks prv5
			ON ph.SeasonKey = prv5.SeasonKey
			AND ph.GameweekKey = prv5.GameweekKey
			WHERE pa.PlayerPositionKey = @PlayerPositionKey
			AND prv5.GameweekRank <= 5
			GROUP BY ph.PlayerKey, pa.TeamKey
		),
		TotalPlayerTeamMinutes AS
		(
			SELECT pa.PlayerKey, 
			pa.TeamKey,
			COUNT(DISTINCT tgf.GameweekFixtureKey) AS TotalPlayerTeamGames
			FROM dbo.DimTeamGameweekFixture tgf
			INNER JOIN dbo.DimPlayerAttribute pa
			ON tgf.TeamKey = pa.TeamKey
			AND tgf.SeasonKey = pa.SeasonKey
			INNER JOIN Previous5Gameweeks prv5
			ON tgf.SeasonKey = prv5.SeasonKey
			AND tgf.GameweekKey = prv5.GameweekKey
			WHERE prv5.GameweekRank <= 5
			GROUP BY pa.PlayerKey, pa.TeamKey
			--ORDER BY pa.TeamKey, pa.PlayerKey
		)
		SELECT tpm.PlayerKey,
		p.PlayerName,
		SUM(tpm.TotalPlayerMinutes) AS TotalPlayerMinutes,
		SUM(tptm.TotalPlayerTeamGames) AS TotalPlayerGames,
		(SUM(tptm.TotalPlayerTeamGames) * 90) AS TotalPlayerTeamMinutes,
		SUM(tpm.CurrentPoints) AS CurrentPoints,
		SUM(tpm.TotalPlayerMinutes * 1.00)/(SUM(tptm.TotalPlayerTeamGames) * 90) AS Prev5FractionOfMinutesPlayed
		INTO #PlayingPercentagesPrevious5
		FROM TotalPlayerMinutes tpm
		INNER JOIN TotalPlayerTeamMinutes tptm
		ON tpm.PlayerKey = tptm.PlayerKey
		AND tpm.TeamKey = tptm.TeamKey
		INNER JOIN dbo.DimPlayer p
		ON tpm.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerSeason ps
		ON p.PlayerKey = ps.PlayerKey
		AND ps.SeasonKey = @SeasonKey
		--WHERE p.PlayerKey = @PlayerKey
		GROUP BY tpm.PlayerKey, p .PlayerName
		ORDER BY tpm.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#PlayingPercentagesPrevious5', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		;WITH TotalPlayerTeamMinutes AS
		(
			SELECT pa.PlayerKey, 
			pa.TeamKey,
			COUNT(DISTINCT tgf.GameweekFixtureKey) AS TotalPlayerTeamGames
			FROM dbo.DimTeamGameweekFixture tgf
			INNER JOIN dbo.DimPlayerAttribute pa
			ON tgf.TeamKey = pa.TeamKey
			AND tgf.SeasonKey = pa.SeasonKey
			WHERE (tgf.SeasonKey < @CurrentSeasonKey OR (tgf.SeasonKey = @CurrentSeasonKey AND tgf.GameweekKey < @CurrentGameweekKey))
			GROUP BY pa.PlayerKey, pa.TeamKey
			--ORDER BY pa.TeamKey, pa.PlayerKey
		),
		TotalPlayerMinutes AS
		(
			SELECT ph.PlayerKey,
			pa.TeamKey,
			SUM(ph.[Minutes]) AS TotalPlayerMinutes,
			SUM(ph.TotalPoints) AS CurrentPoints
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND ph.SeasonKey = pa.SeasonKey
			WHERE pa.PlayerPositionKey = @PlayerPositionKey
			GROUP BY ph.PlayerKey, pa.TeamKey
		)
		SELECT tpm.PlayerKey,
		p.PlayerName,
		SUM(tpm.TotalPlayerMinutes) AS TotalPlayerMinutes,
		SUM(tptm.TotalPlayerTeamGames) AS TotalPlayerGames,
		(SUM(tptm.TotalPlayerTeamGames) * 90) AS TotalPlayerTeamMinutes,
		SUM(tpm.CurrentPoints) AS CurrentPoints,
		SUM(tpm.TotalPlayerMinutes * 1.00)/(SUM(tptm.TotalPlayerTeamGames) * 90) AS OverallFractionOfMinutesPlayed
		INTO #PlayingPercentages
		FROM TotalPlayerMinutes tpm
		INNER JOIN TotalPlayerTeamMinutes tptm
		ON tpm.PlayerKey = tptm.PlayerKey
		AND tpm.TeamKey = tptm.TeamKey
		INNER JOIN dbo.DimPlayer p
		ON tpm.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerSeason ps
		ON p.PlayerKey = ps.PlayerKey
		AND ps.SeasonKey = @SeasonKey
		--WHERE p.PlayerKey = @PlayerKey
		GROUP BY tpm.PlayerKey, p .PlayerName
		ORDER BY tpm.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='#PlayingPercentages', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Combine all data for overall prediction
		;WITH PlayerPredictions AS
		(
			SELECT PlayerKey,
			ChanceOfPlayingNextRound,
			Diff1Points + Diff2Points + Diff3Points + Diff4Points + Diff5Points AS PredictedPointsAll,
			Diff1Points5 + Diff2Points5 + Diff3Points5 + Diff4Points5 + Diff5Points5 AS PredictedPoints5,
			Diff1Points10 + Diff2Points10 + Diff3Points10 + Diff4Points10 + Diff5Points10 AS PredictedPoints10,
			TotalGames AS TotalGames
			FROM #PlayerPredictions
		),
		PlayerPredictionsWeighted AS
		(
			SELECT PlayerKey,
			ChanceOfPlayingNextRound,
			PredictedPointsAll,
			PredictedPoints5,
			PredictedPoints10,
			(PredictedPointsAll * @PredictionPointsAllWeighting) AS PredictedPointsAllWeighted,
			(PredictedPoints5 * @PredictionPoints5Weighting) AS PredictedPoints5Weighted,
			(PredictedPoints10 * @PredictionPoints10Weighting) AS PredictedPoints10Weighted,
			TotalGames
			FROM PlayerPredictions
		),
		OverallPPG AS
		(
			SELECT PlayerKey,
			PPG * @Gameweeks AS OverallPPGPredictionPoints,
			PPG * @Gameweeks * 100 AS OverallPPGPredictionPointsWeighted
			FROM #OverallPPG
		),
		OverallDifficultyPPG AS
		(
			SELECT p.PlayerKey,
			(SUM(od.Points) * 1.00/SUM(od.Games)) AS OverallDifficultyPPGPredictionPoints,
			(SUM(od.Points) * 1.00/SUM(od.Games)) * 100 AS OverallDifficultyPPGPredictionPointsWeighted,
			SUM(od.Games) AS TotalGames
			FROM dbo.DimPlayer p
			INNER JOIN dbo.DimPlayerAttribute pa
			ON p.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN #Fixtures f
			ON pa.TeamKey = f.TeamKey
			INNER JOIN #OverallDifficultyPPG od
			ON f.TeamDifficulty = od.TeamDifficulty
			AND f.OpponentDifficulty = od.OppositionTeamDifficulty
			GROUP BY p.PlayerKey
			--ORDER BY p.PlayerKey
		),
		OverallTeamPPG AS
		(
			SELECT p.PlayerKey,
			((SUM(ot.Points) * 1.00)/SUM(ot.Games)) AS OverallTeamPPGPredictionPoints,
			((SUM(ot.Points) * 1.00)/SUM(ot.Games)) * 100 AS OverallTeamPPGPredictionPointsWeighted,
			SUM(ot.Games) AS TotalGames
			FROM dbo.DimPlayer p
			INNER JOIN dbo.DimPlayerAttribute pa
			ON p.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN #Fixtures f
			ON pa.TeamKey = f.TeamKey
			INNER JOIN #OverallTeamPPG ot
			ON f.TeamKey = ot.TeamKey
			AND f.OpponentDifficulty = ot.OppositionTeamDifficulty
			AND f.IsHome = ot.WasHome
			GROUP BY p.PlayerKey
		),
		PlayingPercentages AS
		(
			SELECT pct.PlayerKey,
			pct.TotalPlayerGames,
			pct.TotalPlayerMinutes,
			pct.TotalPlayerTeamMinutes,
			pct.CurrentPoints,
			pct.OverallFractionOfMinutesPlayed,
			pctprv5.Prev5FractionOfMinutesPlayed,
			CASE
				WHEN pct.OverallFractionOfMinutesPlayed > 0.7 AND pctprv5.Prev5FractionOfMinutesPlayed > 0.5 THEN 1.00
				WHEN pctprv5.Prev5FractionOfMinutesPlayed > 0.8 THEN 1.00
				WHEN pct.OverallFractionOfMinutesPlayed > 0.3 AND pctprv5.Prev5FractionOfMinutesPlayed < 0.5 THEN pct.OverallFractionOfMinutesPlayed
				WHEN pct.OverallFractionOfMinutesPlayed <= 0.3 AND pctprv5.Prev5FractionOfMinutesPlayed > 0.3 THEN pct.OverallFractionOfMinutesPlayed
				ELSE 0
			END AS StartingProbability
			FROM #PlayingPercentages pct
			FULL OUTER JOIN #PlayingPercentagesPrevious5 pctprv5
			ON pct.PlayerKey = pctprv5.PlayerKey
		),
		CurrentCost AS
		(
			SELECT pgs.PlayerKey,
			SeasonKey,
			GameweekKey,
			Cost
			FROM dbo.FactPlayerGameweekStatus pgs
			INNER JOIN 
			(
				SELECT PlayerKey,
				MAX(FactPlayerGameweekStatusKey) AS MaxPlayerGameweekStatusKey
				FROM dbo.FactPlayerGameweekStatus
				GROUP BY PlayerKey
			) maxkey
			ON pgs.PlayerKey = maxkey.PlayerKey
			AND pgs.FactPlayerGameweekStatusKey = maxkey.MaxPlayerGameweekStatusKey
			--ORDER BY pgs.PlayerKey, SeasonKey, GameweekKey
		)
		INSERT INTO #FinalPrediction
		SELECT
			@SeasonKey AS SeasonKey,
			@GameweekStart AS GameweekStartKey,
			@Gameweeks AS Gameweeks,
			@PlayerPositionKey AS PlayerPositionKey,
			@PredictionPointsAllWeighting AS PredictionPointsAllWeighting,
			@PredictionPoints5Weighting AS PredictionPoints5Weighting,
			@PredictionPoints10Weighting AS PredictionPoints10Weighting,
			ppw.PlayerKey,
			p.PlayerName,
			cost.Cost,
			pp.PlayerPositionShort AS PlayerPosition,
			t.TeamName,
			pct.TotalPlayerGames,
			pct.TotalPlayerMinutes,
			pct.CurrentPoints,
			ppw.PredictedPointsAll,
			ppw.PredictedPoints5,
			ppw.PredictedPoints10,
			oppg.OverallPPGPredictionPoints,
			otppg.OverallTeamPPGPredictionPoints,
			odppg.OverallDifficultyPPGPredictionPoints,
			pct.OverallFractionOfMinutesPlayed,
			pct.Prev5FractionOfMinutesPlayed,
			pct.StartingProbability,
			ppw.TotalGames,
			otppg.TotalGames AS TeamTotalGames,
			odppg.TotalGames AS DifficultyTotalGames,
			CASE 
				WHEN ppw.TotalGames >= 10 THEN 1
				WHEN ppw.TotalGames < 10 AND otppg.TotalGames >= 100 THEN 2
				ELSE 3
			END AS PredictedPointsPath,
			CASE 
				WHEN ppw.TotalGames >= 10 THEN
					--((ppw.PredictedPoints + ppw.PredictedPoints5 + ppw.PredictedPoints10 + oppg.OverallPPGPredictionPoints) / 4) * ISNULL(pct.FractionOfMinutesPlayed, 1.00)
					((ppw.PredictedPointsAll + ppw.PredictedPoints5 + ppw.PredictedPoints10 + oppg.OverallPPGPredictionPoints) / 4) * ISNULL(pct.StartingProbability, 0)
				WHEN ppw.TotalGames < 10 AND otppg.TotalGames >= 100 THEN
					--((ppw.PredictedPoints + ppw.PredictedPoints5 + ppw.PredictedPoints10 + otppg.OverallTeamPPGPredictionPoints) / 4) * ISNULL(pct.FractionOfMinutesPlayed, 1.00)
					((ppw.PredictedPointsAll + ppw.PredictedPoints5 + ppw.PredictedPoints10 + otppg.OverallTeamPPGPredictionPoints) / 4) * ISNULL(pct.StartingProbability, 0)
				ELSE
					--((ppw.PredictedPoints + ppw.PredictedPoints5 + ppw.PredictedPoints10 + odppg.OverallDifficultyPPGPredictionPoints + otppg.OverallTeamPPGPredictionPoints) / 5) * ISNULL(pct.FractionOfMinutesPlayed, 1.00)
					((ppw.PredictedPointsAll + ppw.PredictedPoints5 + ppw.PredictedPoints10 + odppg.OverallDifficultyPPGPredictionPoints + otppg.OverallTeamPPGPredictionPoints) / 5) * ISNULL(pct.StartingProbability, 0)
			END
			AS PredictedPoints,
			CASE 
				WHEN ppw.TotalGames >= 10 THEN
					((ppw.PredictedPointsAllWeighted + ppw.PredictedPoints5Weighted + ppw.PredictedPoints10Weighted + oppg.OverallPPGPredictionPointsWeighted) / @TotalPredictionPointsWeighting) * ISNULL(pct.StartingProbability, 0)
				WHEN ppw.TotalGames < 10 AND otppg.TotalGames >= 100 THEN
					((ppw.PredictedPointsAllWeighted + ppw.PredictedPoints5Weighted + ppw.PredictedPoints10Weighted + otppg.OverallTeamPPGPredictionPointsWeighted) / @TotalPredictionPointsWeighting) * ISNULL(pct.StartingProbability, 0)
				ELSE
					((ppw.PredictedPointsAllWeighted + ppw.PredictedPoints5Weighted + ppw.PredictedPoints10Weighted + otppg.OverallTeamPPGPredictionPointsWeighted + odppg.OverallDifficultyPPGPredictionPointsWeighted) / @TotalExtraPredictionPointsWeighting) * ISNULL(pct.StartingProbability, 0)
			END AS PredictedPointsWeighted,
			ppw.ChanceOfPlayingNextRound
		FROM PlayerPredictionsWeighted ppw
		INNER JOIN dbo.DimPlayer p
		ON ppw.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN CurrentCost cost
		ON p.PlayerKey = cost.PlayerKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		--LEFT JOIN #PlayingPercentages pct
		--ON ppw.PlayerKey = pct.PlayerKey
		INNER JOIN OverallPPG oppg
		ON ppw.PlayerKey = oppg.PlayerKey
		LEFT JOIN PlayingPercentages pct
		ON ppw.PlayerKey = pct.PlayerKey
		INNER JOIN OverallDifficultyPPG odppg
		ON ppw.PlayerKey = odppg.PlayerKey
		INNER JOIN OverallTeamPPG otppg
		ON ppw.PlayerKey = otppg.PlayerKey;
		--WHERE ISNULL(ppw.ChanceOfPlayingNextRound, 100) > 0
		--ORDER BY PredictedPoints DESC;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='Final query', @Time=@time OUTPUT;
		END

		IF @Debug = 1
		BEGIN

			SELECT @SeasonKey AS SeasonKey, @GameweekStart AS GameweekStart, @GameweekEnd AS GameweekEnd, @GameweekStartDate AS GameweekStartDate, @Gameweeks AS Gameweeks;

			IF @PlayerKey IS NULL
			BEGIN

				SELECT '#Fixtures';

				SELECT *
				FROM #Fixtures;

				SELECT 'CTE AllPPG (used to create #PlayerPPG)';

				SELECT ppg.PlayerKey, ppg.PlayerPositionKey, ppg.OpponentDifficulty, ppg.Games, ppg.PPG, ISNULL(prv5.PPG,0) AS PPG5, ISNULL(prv10.PPG,0) AS PPG10
				FROM dbo.PlayerPointsPerGame ppg
				LEFT JOIN dbo.PlayerPointsPerGamePrevious5 prv5
				ON ppg.PlayerKey = prv5.PlayerKey
				AND ppg.PlayerPositionKey = prv5.PlayerPositionKey
				AND ppg.OpponentDifficulty = prv5.OpponentDifficulty
				AND prv5.SeasonKey = @SeasonKey
				AND prv5.GameweekKey = (@GameweekStart - 1)
				LEFT JOIN dbo.PlayerPointsPerGamePrevious10 prv10
				ON prv5.SeasonKey = prv10.SeasonKey
				AND prv5.GameweekKey = prv10.GameweekKey
				AND prv5.PlayerKey = prv10.PlayerKey
				AND prv5.PlayerPositionKey = prv10.PlayerPositionKey
				AND prv5.OpponentDifficulty = prv10.OpponentDifficulty
				AND prv10.SeasonKey = @SeasonKey
				AND prv10.GameweekKey = (@GameweekStart - 1);

				SELECT '#PlayerPPG';

				SELECT p.PlayerName, ppg.*
				FROM #PlayerPPG ppg
				INNER JOIN dbo.DimPlayer p
				ON ppg.PlayerKey = p.PlayerKey
				ORDER BY ppg.PlayerKey;

				SELECT '#FixtureDifficulty CTE LatestPlayerNews';

				SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
				FROM
				(
					SELECT DISTINCT PlayerKey 
					FROM dbo.FactPlayerGameweekNews 
				) fpgn1
				CROSS APPLY
				(
					SELECT TOP (1) fpgn2.*
					FROM dbo.FactPlayerGameweekNews fpgn2
					WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
					ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
				) ca
				INNER JOIN dbo.FactPlayerGameweekStatus fpgs
				ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
				ORDER BY ca.PlayerKey;

				SELECT '#FixtureDifficulty CTE PlayerChanceOfPlaying';
			
				;WITH LatestPlayerNews AS
				(
					SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
					FROM
					(
						SELECT DISTINCT PlayerKey 
						FROM dbo.FactPlayerGameweekNews 
					) fpgn1
					CROSS APPLY
					(
						SELECT TOP (1) fpgn2.*
						FROM dbo.FactPlayerGameweekNews fpgn2
						WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
						ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
					) ca
					INNER JOIN dbo.FactPlayerGameweekStatus fpgs
					ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
				)
				SELECT p.PlayerKey, 
				pa.TeamKey,
				lpn.ChanceOfPlayingNextRound,
				CASE 
					WHEN ISNULL(lpn.News,'') <> '' AND CHARINDEX('Unknown return date', News) = 0 AND lpn.PlayerStatus IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(lpn.News), CHARINDEX(' ', REVERSE(lpn.News), CHARINDEX(' ',REVERSE(lpn.News))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
					ELSE @GameweekStartDate
				END AS StartDate
				FROM dbo.DimPlayer p
				INNER JOIN dbo.DimPlayerAttribute pa
				ON p.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				LEFT JOIN LatestPlayerNews lpn
				ON p.PlayerKey = lpn.PlayerKey
				WHERE pa.PlayerPositionKey = @PlayerPositionKey
				ORDER BY p.PlayerKey;

				SELECT '#FixtureDifficulty';

				SELECT p.PlayerName, fd.*
				FROM #FixtureDifficulty fd
				INNER JOIN dbo.DimPlayer p
				ON fd.PlayerKey = p.PlayerKey
				ORDER BY fd.PlayerKey;

		SELECT p.PlayerKey,
		SUM(CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff1GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff2GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff3GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff4GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff5GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff1GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff2GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff3GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff4GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff5GamesAway,
		COUNT(1) AS TotalGames
		FROM dbo.DimPlayer p
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN #Fixtures f
		ON pa.TeamKey = f.TeamKey
		GROUP BY p.PlayerKey
		ORDER BY p.PlayerKey;

		;WITH LatestPlayerNews AS
		(
			SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
			FROM
			(
				SELECT DISTINCT PlayerKey 
				FROM dbo.FactPlayerGameweekNews 
			) fpgn1
			CROSS APPLY
			(
				SELECT TOP (1) fpgn2.*
				FROM dbo.FactPlayerGameweekNews fpgn2
				WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
				ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
			) ca
			INNER JOIN dbo.FactPlayerGameweekStatus fpgs
			ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
		),
		PlayerChanceOfPlaying AS
		(
			SELECT p.PlayerKey, 
			pa.TeamKey,
			lpn.ChanceOfPlayingNextRound,
			CASE 
				WHEN ISNULL(lpn.News,'') <> '' AND CHARINDEX('Unknown return date', News) = 0 AND lpn.PlayerStatus IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(lpn.News), CHARINDEX(' ', REVERSE(lpn.News), CHARINDEX(' ',REVERSE(lpn.News))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
				ELSE @GameweekStartDate
			END AS StartDate
			FROM dbo.DimPlayer p
			INNER JOIN dbo.DimPlayerAttribute pa
			ON p.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			LEFT JOIN LatestPlayerNews lpn
			ON p.PlayerKey = lpn.PlayerKey
			WHERE pa.PlayerPositionKey = @PlayerPositionKey
		)
		SELECT p.PlayerKey,
		f.KickoffDate,
		ch.StartDate,
		ch.ChanceOfPlayingNextRound,
		CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff1GamesHome,
		CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff2GamesHome,
		CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff3GamesHome,
		CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff4GamesHome,
		CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff5GamesHome,
		CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff1GamesAway,
		CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff2GamesAway,
		CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff3GamesAway,
		CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff4GamesAway,
		CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff5GamesAway
		FROM dbo.DimPlayer p
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN #Fixtures f
		ON pa.TeamKey = f.TeamKey
		LEFT JOIN PlayerChanceOfPlaying ch
		ON p.PlayerKey = ch.PlayerKey
		ORDER BY p.PlayerKey, f.GameweekFixtureKey;

				SELECT '#PlayerPredictions';

				SELECT p.PlayerName, pp.*
				FROM #PlayerPredictions pp
				INNER JOIN dbo.DimPlayer p
				ON pp.PlayerKey = p.PlayerKey
				ORDER BY pp.PlayerKey;

				SELECT 'CTE PlayerPredictionsWeighted';

				;WITH PlayerPredictions AS
				(
					SELECT PlayerKey,
					MIN(ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
					SUM(Diff1Points + Diff2Points + Diff3Points + Diff4Points + Diff5Points) AS PredictedPoints,
					SUM(Diff1Points5 + Diff2Points5 + Diff3Points5 + Diff4Points5 + Diff5Points5) AS PredictedPoints5,
					SUM(Diff1Points10 + Diff2Points10 + Diff3Points10 + Diff4Points10 + Diff5Points10) AS PredictedPoints10,
					SUM(TotalGames) AS TotalGames
					FROM #PlayerPredictions
					GROUP BY PlayerKey
				)
				SELECT PlayerKey,
				ChanceOfPlayingNextRound,
				PredictedPoints,
				PredictedPoints5,
				PredictedPoints10,
				(PredictedPoints * @PredictionPointsAllWeighting) AS PredictedPointsWeighted,
				(PredictedPoints5 * @PredictionPoints5Weighting) AS PredictedPoints5Weighted,
				(PredictedPoints10 * @PredictionPoints10Weighting) AS PredictedPoints10Weighted,
				TotalGames
				FROM PlayerPredictions
				ORDER BY PlayerKey;;

				SELECT 'CTE OverallPPG';

				SELECT PlayerKey,
				PPG * @Gameweeks AS OverallPPGPredictionPoints,
				PPG * @Gameweeks * 100 AS OverallPPGPredictionPointsWeighted
				FROM #OverallPPG
				ORDER BY PlayerKey;;

				SELECT 'CTE OverallDifficultyPPG';

				SELECT p.PlayerKey,
				(SUM(od.Points) * 1.00/SUM(od.Games)) AS OverallDifficultyPPGPredictionPoints,
				(SUM(od.Points) * 1.00/SUM(od.Games)) * 100 AS OverallDifficultyPPGPredictionPointsWeighted,
				SUM(od.Games) AS TotalGames
				FROM dbo.DimPlayer p
				INNER JOIN dbo.DimPlayerAttribute pa
				ON p.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				INNER JOIN #Fixtures f
				ON pa.TeamKey = f.TeamKey
				INNER JOIN #OverallDifficultyPPG od
				ON f.TeamDifficulty = od.TeamDifficulty
				AND f.OpponentDifficulty = od.OppositionTeamDifficulty
				GROUP BY p.PlayerKey
				ORDER BY p.PlayerKey;

				SELECT 'CTE OverallTeamPPG';

				SELECT p.PlayerKey,
				((SUM(ot.Points) * 1.00)/SUM(ot.Games)) AS OverallTeamPPGPredictionPoints,
				((SUM(ot.Points) * 1.00)/SUM(ot.Games)) * 100 AS OverallTeamPPGPredictionPointsWeighted,
				SUM(ot.Games) AS TotalGames
				FROM dbo.DimPlayer p
				INNER JOIN dbo.DimPlayerAttribute pa
				ON p.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				INNER JOIN #Fixtures f
				ON pa.TeamKey = f.TeamKey
				INNER JOIN #OverallTeamPPG ot
				ON f.TeamKey = ot.TeamKey
				AND f.OpponentDifficulty = ot.OppositionTeamDifficulty
				AND f.IsHome = ot.WasHome
				GROUP BY p.PlayerKey
				ORDER BY p.PlayerKey;

			END
			ELSE
			BEGIN

				SELECT '#Fixtures';
			
				SELECT *
				FROM #Fixtures f
				WHERE EXISTS
				(
					SELECT 1
					FROM dbo.DimPlayer p
					INNER JOIN dbo.DimPlayerAttribute pa
					ON p.PlayerKey = pa.PlayerKey
					AND pa.SeasonKey = @SeasonKey
					WHERE p.PlayerKey = @PlayerKey
					AND f.TeamKey = pa.TeamKey
					--AND (f.TeamKey = teamKey OR f.OpponentTeamKey = teamKey)
				)
				ORDER BY f.GameweekFixtureKey, f.SeasonKey, f.GameweekKey, f.TeamKey, f.OpponentTeamKey;

				SELECT 'CTE AllPPG (used to create #PlayerPPG)';

				SELECT ppg.PlayerKey, ppg.PlayerPositionKey, ppg.OpponentDifficulty, ppg.Games, ppg.PPG, ISNULL(prv5.PPG,0) AS PPG5, ISNULL(prv10.PPG,0) AS PPG10
				FROM dbo.PlayerPointsPerGame ppg
				LEFT JOIN dbo.PlayerPointsPerGamePrevious5 prv5
				ON ppg.PlayerKey = prv5.PlayerKey
				AND ppg.PlayerPositionKey = prv5.PlayerPositionKey
				AND ppg.OpponentDifficulty = prv5.OpponentDifficulty
				AND prv5.SeasonKey = @SeasonKey
				AND prv5.GameweekKey = (@GameweekStart - 1)
				LEFT JOIN dbo.PlayerPointsPerGamePrevious10 prv10
				ON prv5.SeasonKey = prv10.SeasonKey
				AND prv5.GameweekKey = prv10.GameweekKey
				AND prv5.PlayerKey = prv10.PlayerKey
				AND prv5.PlayerPositionKey = prv10.PlayerPositionKey
				AND prv5.OpponentDifficulty = prv10.OpponentDifficulty
				AND prv10.SeasonKey = @SeasonKey
				AND prv10.GameweekKey = (@GameweekStart - 1)
				WHERE ppg.PlayerKey = @PlayerKey;

				SELECT '#PlayerPPG';
			
				SELECT *
				FROM #PlayerPPG
				WHERE PlayerKey = @PlayerKey;

				SELECT '#FixtureDifficulty CTE LatestPlayerNews';

				SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
				FROM
				(
					SELECT DISTINCT PlayerKey 
					FROM dbo.FactPlayerGameweekNews 
				) fpgn1
				CROSS APPLY
				(
					SELECT TOP (1) fpgn2.*
					FROM dbo.FactPlayerGameweekNews fpgn2
					WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
					ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
				) ca
				INNER JOIN dbo.FactPlayerGameweekStatus fpgs
				ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
				WHERE ca.PlayerKey = @PlayerKey;

				SELECT '#FixtureDifficulty CTE PlayerChanceOfPlaying';
			
				;WITH LatestPlayerNews AS
				(
					SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
					FROM
					(
						SELECT DISTINCT PlayerKey 
						FROM dbo.FactPlayerGameweekNews 
					) fpgn1
					CROSS APPLY
					(
						SELECT TOP (1) fpgn2.*
						FROM dbo.FactPlayerGameweekNews fpgn2
						WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
						ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
					) ca
					INNER JOIN dbo.FactPlayerGameweekStatus fpgs
					ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
				)
				SELECT p.PlayerKey, 
				pa.TeamKey,
				lpn.ChanceOfPlayingNextRound,
				CASE 
					WHEN ISNULL(lpn.News,'') <> '' AND CHARINDEX('Unknown return date', News) = 0 AND lpn.PlayerStatus IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(lpn.News), CHARINDEX(' ', REVERSE(lpn.News), CHARINDEX(' ',REVERSE(lpn.News))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
					ELSE @GameweekStartDate
				END AS StartDate
				FROM dbo.DimPlayer p
				INNER JOIN dbo.DimPlayerAttribute pa
				ON p.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				LEFT JOIN LatestPlayerNews lpn
				ON p.PlayerKey = lpn.PlayerKey
				WHERE pa.PlayerPositionKey = @PlayerPositionKey
				AND p.PlayerKey = @PlayerKey;

				SELECT '#FixtureDifficulty';
			
				SELECT *
				FROM #FixtureDifficulty
				WHERE PlayerKey = @PlayerKey;

		SELECT p.PlayerKey,
		SUM(CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff1GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff2GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff3GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff4GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 1 THEN 1 ELSE 0 END) AS Diff5GamesHome,
		SUM(CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff1GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff2GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff3GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff4GamesAway,
		SUM(CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 0 THEN 1 ELSE 0 END) AS Diff5GamesAway,
		COUNT(1) AS TotalGames
		FROM dbo.DimPlayer p
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN #Fixtures f
		ON pa.TeamKey = f.TeamKey
		WHERE p.PlayerKey = @PlayerKey
		GROUP BY p.PlayerKey
		ORDER BY p.PlayerKey;

		;WITH LatestPlayerNews AS
		(
			SELECT ca.*, fpgs.PlayerStatus, fpgs.ChanceOfPlayingNextRound
			FROM
			(
				SELECT DISTINCT PlayerKey 
				FROM dbo.FactPlayerGameweekNews 
			) fpgn1
			CROSS APPLY
			(
				SELECT TOP (1) fpgn2.*
				FROM dbo.FactPlayerGameweekNews fpgn2
				WHERE fpgn1.PlayerKey = fpgn2.PlayerKey
				ORDER BY fpgn2.FactPlayerGameweekStatusKey DESC
			) ca
			INNER JOIN dbo.FactPlayerGameweekStatus fpgs
			ON ca.FactPlayerGameweekStatusKey = fpgs.FactPlayerGameweekStatusKey
		),
		PlayerChanceOfPlaying AS
		(
			SELECT p.PlayerKey, 
			pa.TeamKey,
			lpn.ChanceOfPlayingNextRound,
			CASE 
				WHEN ISNULL(lpn.News,'') <> '' AND CHARINDEX('Unknown return date', News) = 0 AND lpn.PlayerStatus IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(lpn.News), CHARINDEX(' ', REVERSE(lpn.News), CHARINDEX(' ',REVERSE(lpn.News))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
				ELSE @GameweekStartDate
			END AS StartDate
			FROM dbo.DimPlayer p
			INNER JOIN dbo.DimPlayerAttribute pa
			ON p.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			LEFT JOIN LatestPlayerNews lpn
			ON p.PlayerKey = lpn.PlayerKey
			WHERE pa.PlayerPositionKey = @PlayerPositionKey
		)
		SELECT p.PlayerKey,
		f.KickoffDate,
		ch.StartDate,
		ch.ChanceOfPlayingNextRound,
		CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff1GamesHome,
		CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff2GamesHome,
		CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff3GamesHome,
		CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff4GamesHome,
		CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 1 THEN 1 ELSE 0 END AS Diff5GamesHome,
		CASE WHEN f.OpponentDifficulty = 1 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff1GamesAway,
		CASE WHEN f.OpponentDifficulty = 2 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff2GamesAway,
		CASE WHEN f.OpponentDifficulty = 3 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff3GamesAway,
		CASE WHEN f.OpponentDifficulty = 4 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff4GamesAway,
		CASE WHEN f.OpponentDifficulty = 5 AND f.IsHome = 0 THEN 1 ELSE 0 END AS Diff5GamesAway
		FROM dbo.DimPlayer p
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN #Fixtures f
		ON pa.TeamKey = f.TeamKey
		LEFT JOIN PlayerChanceOfPlaying ch
		ON p.PlayerKey = ch.PlayerKey
		WHERE p.PlayerKey = @PlayerKey;

				SELECT '#PlayerPredictions';
			
				SELECT p.PlayerName, pp.*
				FROM #PlayerPredictions pp
				INNER JOIN dbo.DimPlayer p
				ON pp.PlayerKey = p.PlayerKey
				WHERE pp.PlayerKey = @PlayerKey;

				SELECT 'CTE PlayerPredictions';
			
				SELECT PlayerKey,
				MIN(ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
				SUM(Diff1Points + Diff2Points + Diff3Points + Diff4Points + Diff5Points) AS PredictedPoints,
				SUM(Diff1Points5 + Diff2Points5 + Diff3Points5 + Diff4Points5 + Diff5Points5) AS PredictedPoints5,
				SUM(Diff1Points10 + Diff2Points10 + Diff3Points10 + Diff4Points10 + Diff5Points10) AS PredictedPoints10,
				SUM(TotalGames) AS TotalGames
				FROM #PlayerPredictions
				WHERE PlayerKey = @PlayerKey
				GROUP BY PlayerKey;

				SELECT 'CTE PlayerPredictionsWeighted';

				;WITH PlayerPredictions AS
				(
					SELECT PlayerKey,
					MIN(ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
					SUM(Diff1Points + Diff2Points + Diff3Points + Diff4Points + Diff5Points) AS PredictedPoints,
					SUM(Diff1Points5 + Diff2Points5 + Diff3Points5 + Diff4Points5 + Diff5Points5) AS PredictedPoints5,
					SUM(Diff1Points10 + Diff2Points10 + Diff3Points10 + Diff4Points10 + Diff5Points10) AS PredictedPoints10,
					SUM(TotalGames) AS TotalGames
					FROM #PlayerPredictions
					WHERE PlayerKey = @PlayerKey
					GROUP BY PlayerKey
				)
				SELECT PlayerKey,
				ChanceOfPlayingNextRound,
				PredictedPoints,
				PredictedPoints5,
				PredictedPoints10,
				(PredictedPoints * @PredictionPointsAllWeighting) AS PredictedPointsWeighted,
				(PredictedPoints5 * @PredictionPoints5Weighting) AS PredictedPoints5Weighted,
				(PredictedPoints10 * @PredictionPoints10Weighting) AS PredictedPoints10Weighted,
				TotalGames
				FROM PlayerPredictions
				WHERE PlayerKey = @PlayerKey;

				SELECT 'CTE OverallPPG';

				SELECT PlayerKey,
				PPG * @Gameweeks AS OverallPPGPredictionPoints,
				PPG * @Gameweeks * 100 AS OverallPPGPredictionPointsWeighted
				FROM #OverallPPG
				WHERE PlayerKey = @PlayerKey;

				SELECT 'CTE OverallDifficultyPPG';

				SELECT p.PlayerKey,
				(SUM(od.Points) * 1.00/SUM(od.Games)) AS OverallDifficultyPPGPredictionPoints,
				(SUM(od.Points) * 1.00/SUM(od.Games)) * 100 AS OverallDifficultyPPGPredictionPointsWeighted,
				SUM(od.Games) AS TotalGames
				FROM dbo.DimPlayer p
				INNER JOIN dbo.DimPlayerAttribute pa
				ON p.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				INNER JOIN #Fixtures f
				ON pa.TeamKey = f.TeamKey
				INNER JOIN #OverallDifficultyPPG od
				ON f.TeamDifficulty = od.TeamDifficulty
				AND f.OpponentDifficulty = od.OppositionTeamDifficulty
				WHERE p.PlayerKey = @PlayerKey
				GROUP BY p.PlayerKey;

				SELECT 'CTE OverallTeamPPG';

				SELECT p.PlayerKey,
				((SUM(ot.Points) * 1.00)/SUM(ot.Games)) AS OverallTeamPPGPredictionPoints,
				((SUM(ot.Points) * 1.00)/SUM(ot.Games)) * 100 AS OverallTeamPPGPredictionPointsWeighted,
				SUM(ot.Games) AS TotalGames
				FROM dbo.DimPlayer p
				INNER JOIN dbo.DimPlayerAttribute pa
				ON p.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				INNER JOIN #Fixtures f
				ON pa.TeamKey = f.TeamKey
				INNER JOIN #OverallTeamPPG ot
				ON f.TeamKey = ot.TeamKey
				AND f.OpponentDifficulty = ot.OppositionTeamDifficulty
				AND f.IsHome = ot.WasHome
				WHERE p.PlayerKey = @PlayerKey
				GROUP BY p.PlayerKey;

			END
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