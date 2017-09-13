CREATE PROCEDURE dbo.FutureFixturePlayerPointsPredictionsRefactored
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
		--Add team average PPG for where player doesn't have enough games to make a prediction
		--Add difficulty average PPG for where neither player nor club have enough games to make a prediction

		DECLARE @GameweekEnd INT, @GameweekStartDate DATE, @time DATETIME;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='Starting', @Time=@time OUTPUT;
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

		IF OBJECT_ID('tempdb..#Fixtures') IS NOT NULL
			DROP TABLE #Fixtures;

		IF OBJECT_ID('tempdb..#OverallPPG') IS NOT NULL
			DROP TABLE #OverallPPG;

		IF OBJECT_ID('tempdb..#OverallDifficultyPPG') IS NOT NULL
			DROP TABLE #OverallDifficultyPPG;

		IF OBJECT_ID('tempdb..#OverallTeamPPG') IS NOT NULL
			DROP TABLE #OverallTeamPPG;

		IF OBJECT_ID('tempdb..#PPG') IS NOT NULL
			DROP TABLE #PPG;

		IF OBJECT_ID('tempdb..#PlayerPPG') IS NOT NULL
			DROP TABLE #PlayerPPG;

		IF OBJECT_ID('tempdb..#FixtureDifficulty') IS NOT NULL
			DROP TABLE #FixtureDifficulty;

		IF OBJECT_ID('tempdb..#PlayerPredictions') IS NOT NULL
			DROP TABLE #PlayerPredictions;

		IF OBJECT_ID('tempdb..#PlayingPercentages') IS NOT NULL
			DROP TABLE #PlayingPercentages;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='Pre #Fixtures', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END
	
		--Get list of fixtures in the gameweeks to be analysed
		SELECT *
		INTO #Fixtures
		FROM dbo.fnGetFixtures(@SeasonKey, @PlayerPositionKey, @GameweekStart, @GameweekEnd);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#Fixtures', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Create temp table with overall points per game
		SELECT *
		INTO #OverallPPG
		FROM dbo.fnGetOverallPPG(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#OverallPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Create temp table with overall points per game per team difficulty and opponent difficulty
		SELECT *
		INTO #OverallDifficultyPPG
		FROM dbo.fnGetOverallDifficultyPPG(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#OverallDifficultyPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END
	
		--Create temp table with overall points per game per team, opponent difficulty, and home/away
		SELECT *
		INTO #OverallTeamPPG
		FROM dbo.fnGetOverallTeamPPG(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#OverallTeamPPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		--Calculate points per game for each player by difficulty of opposition, and whether at home or away
		CREATE TABLE #PPG 
		(
			PlayerKey INT NOT NULL,
			PlayerPositionKey INT NOT NULL,
			OpponentDifficulty TINYINT NOT NULL,
			--WasHome BIT NOT NULL,
			Points SMALLINT NOT NULL,
			Games TINYINT NOT NULL,
			PlayerMinutes SMALLINT NOT NULL,
			PPG DECIMAL(4,2) NOT NULL,
			PPG5games DECIMAL(4,2),
			PPG10games DECIMAL(4,2)
		);

		INSERT INTO #PPG
		(PlayerKey, PlayerPositionKey, OpponentDifficulty, Points, Games, PlayerMinutes, PPG)
		SELECT *
		FROM dbo.fnGetPPGByPlayerPlayerPositionDificulty(@SeasonKey, @PlayerPositionKey, @MinutesLimit);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PPG', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		CREATE INDEX IX_PPG_PlayerKey_PlayerPositionKey_OpponentDifficulty ON #PPG (PlayerKey, PlayerPositionKey, OpponentDifficulty);

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PPG Index Creation', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		UPDATE #PPG
		SET PPG5games = ph5.PPG5
		FROM #PPG ppg
		INNER JOIN dbo.fnGetPPGByPlayerPlayerPositionDificulty5Gameweeks(@SeasonKey, @PlayerPositionKey, @MinutesLimit) ph5
		ON ppg.PlayerKey = ph5.PlayerKey
		AND ppg.PlayerPositionKey = ph5.PlayerPositionKey
		AND ppg.OpponentDifficulty = ph5.OpponentDifficulty;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PPG - PPG5', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END
	
		UPDATE #PPG
		SET PPG10games = ph10.PPG10
		FROM #PPG ppg
		INNER JOIN dbo.fnGetPPGByPlayerPlayerPositionDificulty10Gameweeks(@SeasonKey, @PlayerPositionKey, @MinutesLimit) ph10
		ON ppg.PlayerKey = ph10.PlayerKey
		AND ppg.PlayerPositionKey = ph10.PlayerPositionKey
		AND ppg.OpponentDifficulty = ph10.OpponentDifficulty;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PPG - PPG10', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		UPDATE #PPG
		SET PPG5games = 0
		WHERE PPG5games IS NULL;

		UPDATE #PPG
		SET PPG10games = 0
		WHERE PPG10games IS NULL;

		--Aggregate to get one row per player (there will only be one row per difficulty so not really aggregation)
		SELECT PlayerKey, 
		PlayerPositionKey,
		SUM(Games) AS TotalGames,
		SUM(CASE WHEN OpponentDifficulty = 1 THEN PPG ELSE 0 END) AS PPG_Diff1,
		SUM(CASE WHEN OpponentDifficulty = 1 THEN PPG5games ELSE 0 END) AS PPG5games_Diff1,
		SUM(CASE WHEN OpponentDifficulty = 1 THEN PPG10games ELSE 0 END) AS PPG10games_Diff1,
		SUM(CASE WHEN OpponentDifficulty = 2 THEN PPG ELSE 0 END) AS PPG_Diff2,
		SUM(CASE WHEN OpponentDifficulty = 2 THEN PPG5games ELSE 0 END) AS PPG5games_Diff2,
		SUM(CASE WHEN OpponentDifficulty = 2 THEN PPG10games ELSE 0 END) AS PPG10games_Diff2,
		SUM(CASE WHEN OpponentDifficulty = 3 THEN PPG ELSE 0 END) AS PPG_Diff3,
		SUM(CASE WHEN OpponentDifficulty = 3 THEN PPG5games ELSE 0 END) AS PPG5games_Diff3,
		SUM(CASE WHEN OpponentDifficulty = 3 THEN PPG10games ELSE 0 END) AS PPG10games_Diff3,
		SUM(CASE WHEN OpponentDifficulty = 4 THEN PPG ELSE 0 END) AS PPG_Diff4,
		SUM(CASE WHEN OpponentDifficulty = 4 THEN PPG5games ELSE 0 END) AS PPG5games_Diff4,
		SUM(CASE WHEN OpponentDifficulty = 4 THEN PPG10games ELSE 0 END) AS PPG10games_Diff4,
		SUM(CASE WHEN OpponentDifficulty = 5 THEN PPG ELSE 0 END) AS PPG_Diff5,
		SUM(CASE WHEN OpponentDifficulty = 5 THEN PPG5games ELSE 0 END) AS PPG5games_Diff5,
		SUM(CASE WHEN OpponentDifficulty = 5 THEN PPG10games ELSE 0 END) AS PPG10games_Diff5
		INTO #PlayerPPG
		FROM #PPG
		GROUP BY PlayerKey, PlayerPositionKey
		ORDER BY PlayerKey, PlayerPositionKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PlayerPPG', @Time=@time OUTPUT;
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
				WHEN ISNULL(lpn.News,'') <> '' AND CHARINDEX('Unknown return date', news) = 0 AND lpn.PlayerStatus IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(lpn.News), CHARINDEX(' ', REVERSE(lpn.News), CHARINDEX(' ',REVERSE(lpn.News))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
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
		MIN(p.ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
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
		FROM #Fixtures f
		LEFT JOIN PlayerChanceOfPlaying p
		ON f.TeamKey = p.TeamKey
		WHERE f.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		AND f.KickoffDate >= p.StartDate
		GROUP BY p.PlayerKey
		ORDER BY p.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#FixtureDifficulty', @Time=@time OUTPUT;
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

		(fd.Diff1GamesHome + fd.Diff1GamesAway) * ppg.PPG5games_Diff1 AS Diff1Points5,
		(fd.Diff2GamesHome + fd.Diff2GamesAway) * ppg.PPG5games_Diff2 AS Diff2Points5,
		(fd.Diff3GamesHome + fd.Diff3GamesAway) * ppg.PPG5games_Diff3 AS Diff3Points5,
		(fd.Diff4GamesHome + fd.Diff4GamesAway) * ppg.PPG5games_Diff4 AS Diff4Points5,
		(fd.Diff5GamesHome + fd.Diff5GamesAway) * ppg.PPG5games_Diff5 AS Diff5Points5,

		(fd.Diff1GamesHome + fd.Diff1GamesAway) * ppg.PPG10games_Diff1 AS Diff1Points10,
		(fd.Diff2GamesHome + fd.Diff2GamesAway) * ppg.PPG10games_Diff2 AS Diff2Points10,
		(fd.Diff3GamesHome + fd.Diff3GamesAway) * ppg.PPG10games_Diff3 AS Diff3Points10,
		(fd.Diff4GamesHome + fd.Diff4GamesAway) * ppg.PPG10games_Diff4 AS Diff4Points10,
		(fd.Diff5GamesHome + fd.Diff5GamesAway) * ppg.PPG10games_Diff5 AS Diff5Points10
		INTO #PlayerPredictions
		FROM #PlayerPPG ppg
		INNER JOIN #FixtureDifficulty fd
		ON ppg.PlayerKey = fd.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PlayerPredictions', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		SELECT TeamKey,
		COUNT(DISTINCT GameweekFixtureKey) AS TotalGames
		INTO #TotalTeamMinutes
		FROM dbo.DimTeamGameweekFixture
		WHERE SeasonKey = @SeasonKey
		AND GameweekKey < @GameweekStart
		GROUP BY TeamKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#TotalTeamMinutes', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		SELECT ph.PlayerKey,
		SUM(ph.[minutes]) AS TotalMinutes,
		MIN(ttm.TotalGames) AS TotalGames,
		SUM(ph.TotalPoints) AS CurrentPoints,
		SUM(ph.[minutes] * 1.00)/(MIN(ttm.TotalGames) * 90) AS FractionOfMinutesPlayed
		INTO #PlayingPercentages
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN #TotalTeamMinutes ttm
		ON pa.TeamKey = ttm.TeamKey
		WHERE ph.SeasonKey = @SeasonKey
		AND pa.PlayerPositionKey = @PlayerPositionKey
		GROUP BY ph.PlayerKey
		ORDER BY ph.PlayerKey;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='#PlayingPercentages', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END
	
		--Combine all data for overall prediction
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
		),
		PlayerPredictionsWeighted AS
		(
			SELECT PlayerKey,
			ChanceOfPlayingNextRound,
			PredictedPoints,
			PredictedPoints5,
			PredictedPoints10,
			(PredictedPoints * 5) AS PredictedPointsWeighted,
			(PredictedPoints5 * 3) AS PredictedPoints5Weighted,
			(PredictedPoints10 * 2) AS PredictedPoints10Weighted,
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
			SUM(od.PPG) AS OverallDifficultyPPGPredictionPoints,
			SUM(od.PPG) * 100 AS OverallDifficultyPPGPredictionPointsWeighted,
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
			SUM(ot.PPG) AS OverallTeamPPGPredictionPoints,
			SUM(ot.PPG) * 100 AS OverallTeamPPGPredictionPointsWeighted,
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
		SELECT TOP (@NumOfRowsToReturn)
		@SeasonKey AS SeasonKey,
		@GameweekStart AS GameweekStartKey,
		@Gameweeks AS Gameweeks,
		@PlayerPositionKey AS PlayerPositionKey,
		ppw.PlayerKey,
		p.PlayerName,
		cost.Cost,
		pp.SingularNameShort AS Position,
		t.TeamName,
		pct.CurrentPoints,
		ppw.TotalGames,
		CASE 
			WHEN ppw.TotalGames >= 10 THEN
				((ppw.PredictedPointsWeighted + ppw.PredictedPoints5Weighted + ppw.PredictedPoints10Weighted + oppg.OverallPPGPredictionPointsWeighted) / 110) * pct.FractionOfMinutesPlayed
			WHEN ppw.TotalGames < 10 AND otppg.TotalGames >= 40 THEN
				((ppw.PredictedPointsWeighted + ppw.PredictedPoints5Weighted + ppw.PredictedPoints10Weighted + otppg.OverallTeamPPGPredictionPointsWeighted) / 110) * pct.FractionOfMinutesPlayed
			ELSE
				((ppw.PredictedPointsWeighted + ppw.PredictedPoints5Weighted + ppw.PredictedPoints10Weighted + otppg.OverallTeamPPGPredictionPointsWeighted + odppg.OverallDifficultyPPGPredictionPointsWeighted) / 210) * pct.FractionOfMinutesPlayed
		END AS PredictedPoints
		FROM PlayerPredictionsWeighted ppw
		INNER JOIN OverallPPG oppg
		ON ppw.PlayerKey = oppg.PlayerKey
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
		INNER JOIN #PlayingPercentages pct
		ON ppw.PlayerKey = pct.PlayerKey
		INNER JOIN OverallDifficultyPPG odppg
		ON ppw.PlayerKey = odppg.PlayerKey
		INNER JOIN OverallTeamPPG otppg
		ON ppw.PlayerKey = otppg.PlayerKey
		--WHERE ISNULL(ppw.ChanceOfPlayingNextRound, 100) > 0
		ORDER BY PredictedPoints DESC;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStoredProcedure @Step='Final query', @Time=@time OUTPUT;
		END

		IF @debug = 1
		BEGIN

			SELECT @SeasonKey AS SeasonKey, @GameweekStart AS GameweekStart, @GameweekEnd AS GameweekEnd, @GameweekStartDate AS GameweekStartDate, @Gameweeks AS Gameweeks;

			IF @PlayerKey IS NULL
			BEGIN

				SELECT '#Fixtures';

				SELECT *
				FROM #Fixtures;

				SELECT '#PPG';

				SELECT *
				FROM #PPG
				ORDER BY PlayerKey, OpponentDifficulty;

				SELECT '#PlayerPPG';

				SELECT p.PlayerName, ppg.*
				FROM #PlayerPPG ppg
				INNER JOIN dbo.DimPlayer p
				ON ppg.PlayerKey = p.PlayerKey
				ORDER BY ppg.PlayerKey;

				SELECT '#FixtureDifficulty';

				SELECT p.PlayerName, fd.*
				FROM #FixtureDifficulty fd
				INNER JOIN dbo.DimPlayer p
				ON fd.PlayerKey = p.PlayerKey
				ORDER BY fd.PlayerKey;

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
				(PredictedPoints * 5) AS PredictedPointsWeighted,
				(PredictedPoints5 * 3) AS PredictedPoints5Weighted,
				(PredictedPoints10 * 2) AS PredictedPoints10Weighted,
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
				SUM(od.PPG) AS OverallDifficultyPPGPredictionPoints,
				SUM(od.PPG) * 100 AS OverallDifficultyPPGPredictionPointsWeighted,
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
				SUM(ot.PPG) AS OverallTeamPPGPredictionPoints,
				SUM(ot.PPG) * 100 AS OverallTeamPPGPredictionPointsWeighted,
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

				SELECT '#PPG';
			
				SELECT *
				FROM #PPG
				WHERE playerKey = @PlayerKey
				ORDER BY OpponentDifficulty;

				SELECT '#PlayerPPG';
			
				SELECT *
				FROM #PlayerPPG
				WHERE playerKey = @PlayerKey;

				SELECT '#FixtureDifficulty';
			
				SELECT *
				FROM #FixtureDifficulty
				WHERE playerKey = @PlayerKey;

				SELECT '#PlayerPredictions';
			
				SELECT p.PlayerName, pp.*
				FROM #PlayerPredictions pp
				INNER JOIN dbo.DimPlayer p
				ON pp.PlayerKey = p.PlayerKey
				WHERE pp.playerKey = @PlayerKey;

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
				(PredictedPoints * 5) AS PredictedPointsWeighted,
				(PredictedPoints5 * 3) AS PredictedPoints5Weighted,
				(PredictedPoints10 * 2) AS PredictedPoints10Weighted,
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
				SUM(od.PPG) AS OverallDifficultyPPGPredictionPoints,
				SUM(od.PPG) * 100 AS OverallDifficultyPPGPredictionPointsWeighted,
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
				SUM(ot.PPG) AS OverallTeamPPGPredictionPoints,
				SUM(ot.PPG) * 100 AS OverallTeamPPGPredictionPointsWeighted,
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