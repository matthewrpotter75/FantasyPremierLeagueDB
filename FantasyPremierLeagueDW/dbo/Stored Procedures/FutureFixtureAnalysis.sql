CREATE PROCEDURE dbo.FutureFixtureAnalysis
(
	--DECLARE
	@SeasonKey INT = NULL,
	@Gameweeks INT = 5,
	@PlayerPositionKey INT,
	@Debug BIT = 0,
	@PlayerKey INT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @GameweekStart INT, @GameweekEnd INT, @GameweekStartDate DATE;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	--Get next gameweek
	SELECT @GameweekStart =
	(
		SELECT TOP 1 GameweekKey
		FROM dbo.DimGameweek
		WHERE DeadlineTime > GETDATE()
		ORDER BY DeadlineTime
	);

	SELECT @GameweekStartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE GameweekKey = @GameweekStart;

	--Get end of gameweek range
	SET @GameweekEnd = @GameweekStart + (@Gameweeks - 1);

	--Get list of fixtures in the gameweeks to be analysed
	SELECT f.GameweekKey, td.Difficulty, f.TeamKey, f.OpponentTeamKey, CAST(gf.KickoffTime AS DATE) AS KickoffDate
	INTO #Fixtures
	FROM dbo.DimTeamGameweekFixture f
	INNER JOIN dbo.FactGameweekFixture gf
	ON f.GameweekFixtureKey = gf.GameweekFixtureKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON f.OpponentTeamKey = td.TeamKey
	AND f.SeasonKey = @SeasonKey
	WHERE f.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd;

	--Create temp table with overall points per game
	SELECT p.PlayerKey,
	pa.PlayerPositionKey,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.playerKey) AS Games,
	SUM(ph.[minutes]) AS PlayerMinutes,
	--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.gameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG
	INTO #OverallPPG
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer p
	ON ph.PlayerKey = p.PlayerKey 
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	WHERE ph.[Minutes] > 45
	AND pa.PlayerPositionKey = @PlayerPositionKey
	GROUP BY p.PlayerKey, pa.PlayerPositionKey;

	--Calculate points per game for each player by difficulty of opposition, and whether at home or away
	CREATE TABLE #PPG 
	(
		PlayerKey INT NOT NULL,
		PlayerPositionKey INT NOT NULL,
		Difficulty TINYINT NOT NULL,
		WasHome BIT NOT NULL,
		Points SMALLINT NOT NULL,
		Games TINYINT NOT NULL,
		PlayerMinutes SMALLINT NOT NULL,
		PPG DECIMAL(4,2) NOT NULL,
		PPG5games DECIMAL(4,2),
		PPG10games DECIMAL(4,2)
	);

	INSERT INTO #PPG
	(PlayerKey, PlayerPositionKey, Difficulty, WasHome, Points, Games, PlayerMinutes, PPG)
	SELECT p.PlayerKey,
	pa.PlayerPositionKey,
	d.Difficulty,
	ph.WasHome,
	SUM(ph.TotalPoints) AS Points,
	COUNT(ph.PlayerKey) AS Games,
	SUM(ph.[Minutes]) AS PlayerMinutes,
	--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer p
	ON ph.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeamDifficulty d
	ON ph.OpponentTeamKey = d.TeamKey
	AND ph.WasHome = d.IsOpponentHome
	WHERE ph.[Minutes] > 45
	AND pa.PlayerPositionKey = @playerPositionKey
	GROUP BY p.PlayerKey, pa.PlayerPositionKey, d.difficulty, ph.WasHome;

	;WITH PlayerHistoryRanked AS
	(
		SELECT PlayerKey,
		GameweekKey,
		ROW_NUMBER() OVER (PARTITION BY PlayerKey ORDER BY GameweekKey DESC) AS GameweekInc,
		TotalPoints,
		[Minutes],
		WasHome,
		OpponentTeamKey
		FROM dbo.FactPlayerHistory
		WHERE [Minutes] > 45
	)
	,PlayerHistory5 AS
	(
		SELECT ph.PlayerKey,
		pa.PlayerPositionKey,
		d.Difficulty,
		ph.WasHome,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[minutes]) AS PlayerMinutes,
		--CASE WHEN SUM(ph.[minutes]) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/SUM(ph.[minutes]) * 90 ELSE 0 END AS PPG5
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG5
		FROM PlayerHistoryRanked ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimTeamDifficulty d
		ON ph.OpponentTeamKey = d.TeamKey
		AND ph.WasHome = d.IsOpponentHome
		WHERE ph.[Minutes] > 45
		--AND ph.GameweekKey BETWEEN (@GameweekStart - 5) AND @GameweekStart
		AND ph.GameweekInc BETWEEN 1 AND 5
		AND pa.PlayerPositionKey = @playerPositionKey
		GROUP BY ph.PlayerKey, pa.PlayerPositionKey, d.Difficulty, ph.WasHome
	)
	UPDATE #PPG
	SET PPG5games = ph5.PPG5
	FROM #PPG ppg
	INNER JOIN PlayerHistory5 ph5
	ON ppg.PlayerKey = ph5.PlayerKey
	AND ppg.PlayerPositionKey = ph5.PlayerPositionKey
	AND ppg.Difficulty = ph5.Difficulty
	AND ppg.WasHome = ph5.WasHome;

	;WITH PlayerHistoryRanked AS
	(
		SELECT PlayerKey,
		GameweekKey,
		ROW_NUMBER() OVER (PARTITION BY PlayerKey ORDER BY GameweekKey DESC) AS GameweekInc,
		TotalPoints,
		[Minutes],
		WasHome,
		OpponentTeamKey
		FROM dbo.FactPlayerHistory
		WHERE [Minutes] > 45
	)
	,PlayerHistory10 AS
	(
		SELECT ph.PlayerKey,
		pa.PlayerPositionKey,
		d.Difficulty,
		ph.WasHome,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		--CASE WHEN SUM(ph.[Minutes]) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/SUM(ph.[Minutes]) * 90 ELSE 0 END AS PPG10
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG10
		FROM PlayerHistoryRanked ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey 
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimTeamDifficulty d
		ON ph.OpponentTeamKey = d.TeamKey
		AND ph.WasHome = d.IsOpponentHome
		WHERE ph.[Minutes] > 45
		--AND ph.GameweekKey BETWEEN (@GameweekStart - 10) AND @GameweekStart
		AND ph.GameweekInc BETWEEN 1 AND 10
		AND pa.PlayerPositionKey = @PlayerPositionKey
		GROUP BY ph.PlayerKey, pa.PlayerPositionKey, d.Difficulty, ph.WasHome
	)
	UPDATE #PPG
	SET PPG10games = ph10.PPG10
	FROM #PPG ppg
	INNER JOIN PlayerHistory10 ph10
	ON ppg.PlayerKey = ph10.PlayerKey
	AND ppg.PlayerPositionKey = ph10.PlayerPositionKey
	AND ppg.Difficulty = ph10.Difficulty
	AND ppg.WasHome = ph10.WasHome;

	UPDATE #PPG
	SET PPG5games = 0
	WHERE PPG5games IS NULL;

	UPDATE #PPG
	SET PPG10games = 0
	WHERE PPG10games IS NULL;

	--Aggregate to get one row per player (there will only be one row per difficulty so not really aggregation)
	SELECT PlayerKey, 
	PlayerPositionKey,
	SUM(CASE WHEN Difficulty = 1 THEN PPG ELSE 0 END) AS PPG_Diff1,
	SUM(CASE WHEN Difficulty = 1 THEN PPG5games ELSE 0 END) AS PPG5games_Diff1,
	SUM(CASE WHEN Difficulty = 1 THEN PPG10games ELSE 0 END) AS PPG10games_Diff1,
	SUM(CASE WHEN Difficulty = 2 THEN PPG ELSE 0 END) AS PPG_Diff2,
	SUM(CASE WHEN Difficulty = 2 THEN PPG5games ELSE 0 END) AS PPG5games_Diff2,
	SUM(CASE WHEN Difficulty = 2 THEN PPG10games ELSE 0 END) AS PPG10games_Diff2,
	SUM(CASE WHEN Difficulty = 3 THEN PPG ELSE 0 END) AS PPG_Diff3,
	SUM(CASE WHEN Difficulty = 3 THEN PPG5games ELSE 0 END) AS PPG5games_Diff3,
	SUM(CASE WHEN Difficulty = 3 THEN PPG10games ELSE 0 END) AS PPG10games_Diff3,
	SUM(CASE WHEN Difficulty = 4 THEN PPG ELSE 0 END) AS PPG_Diff4,
	SUM(CASE WHEN Difficulty = 4 THEN PPG5games ELSE 0 END) AS PPG5games_Diff4,
	SUM(CASE WHEN Difficulty = 4 THEN PPG10games ELSE 0 END) AS PPG10games_Diff4,
	SUM(CASE WHEN Difficulty = 5 THEN PPG ELSE 0 END) AS PPG_Diff5,
	SUM(CASE WHEN Difficulty = 5 THEN PPG5games ELSE 0 END) AS PPG5games_Diff5,
	SUM(CASE WHEN Difficulty = 5 THEN PPG10games ELSE 0 END) AS PPG10games_Diff5
	INTO #PlayerPPG
	FROM #PPG
	GROUP BY PlayerKey, PlayerPositionKey
	ORDER BY PlayerKey, PlayerPositionKey;

	--Get the difficulty of upcoming fixtures for each player
	CREATE TABLE #FixtureDifficulty 
	(
		PlayerKey INT NOT NULL,
		ChanceOfPlayingNextRound DECIMAL(5,2) NULL,
		Diff1Games INT NOT NULL,
		Diff2Games INT NOT NULL,
		Diff3Games INT NOT NULL,
		Diff4Games INT NOT NULL,
		Diff5Games INT NOT NULL,
		TotalGames INT NOT NULL,
		IsHome BIT NOT NULL
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
	Players AS
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
	(PlayerKey, ChanceOfPlayingNextRound, Diff1Games, Diff2Games, Diff3Games, Diff4Games, Diff5Games, TotalGames, IsHome)
	SELECT p.PlayerKey,
	MIN(p.ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
	SUM(CASE WHEN f.Difficulty = 1 THEN 1 ELSE 0 END) AS Diff1Games,
	SUM(CASE WHEN f.Difficulty = 2 THEN 1 ELSE 0 END) AS Diff2Games,
	SUM(CASE WHEN f.Difficulty = 3 THEN 1 ELSE 0 END) AS Diff3Games,
	SUM(CASE WHEN f.Difficulty = 4 THEN 1 ELSE 0 END) AS Diff4Games,
	SUM(CASE WHEN f.Difficulty = 5 THEN 1 ELSE 0 END) AS Diff5Games,
	COUNT(1) AS TotalGames,
	1 AS IsHome
	FROM #Fixtures f
	INNER JOIN Players p
	ON f.TeamKey = p.TeamKey
	WHERE f.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	AND f.KickoffDate >= p.StartDate
	GROUP BY p.PlayerKey

	UNION

	SELECT p.PlayerKey,
	MIN(p.ChanceOfPlayingNextRound) AS ChanceOfPlayingNextRound,
	SUM(CASE WHEN f.Difficulty = 1 THEN 1 ELSE 0 END) AS Diff1Games,
	SUM(CASE WHEN f.Difficulty = 2 THEN 1 ELSE 0 END) AS Diff2Games,
	SUM(CASE WHEN f.Difficulty = 3 THEN 1 ELSE 0 END) AS Diff3Games,
	SUM(CASE WHEN f.Difficulty = 4 THEN 1 ELSE 0 END) AS Diff4Games,
	SUM(CASE WHEN f.Difficulty = 5 THEN 1 ELSE 0 END) AS Diff5Games,
	COUNT(1) AS TotalGames,
	0 AS IsHome
	FROM #Fixtures f
	INNER JOIN Players p
	ON f.OpponentTeamKey = p.TeamKey
	WHERE f.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	AND f.KickoffDate >= p.StartDate
	GROUP BY p.PlayerKey

	ORDER BY p.PlayerKey;

	--Multiply the points per game for each difficulty level by the number of games for that difficulty
	SELECT ppg.PlayerKey,
	fd.ChanceOfPlayingNextRound,
	fd.Diff1Games * ppg.PPG_Diff1 AS Diff1Points,
	fd.Diff2Games * ppg.PPG_Diff2 AS Diff2Points,
	fd.Diff3Games * ppg.PPG_Diff3 AS Diff3Points,
	fd.Diff4Games * ppg.PPG_Diff4 AS Diff4Points,
	fd.Diff5Games * ppg.PPG_Diff5 AS Diff5Points,

	fd.Diff1Games * ppg.PPG5games_Diff1 AS Diff1Points5,
	fd.Diff2Games * ppg.PPG5games_Diff2 AS Diff2Points5,
	fd.Diff3Games * ppg.PPG5games_Diff3 AS Diff3Points5,
	fd.Diff4Games * ppg.PPG5games_Diff4 AS Diff4Points5,
	fd.Diff5Games * ppg.PPG5games_Diff5 AS Diff5Points5,

	fd.Diff1Games * ppg.PPG10games_Diff1 AS Diff1Points10,
	fd.Diff2Games * ppg.PPG10games_Diff2 AS Diff2Points10,
	fd.Diff3Games * ppg.PPG10games_Diff3 AS Diff3Points10,
	fd.Diff4Games * ppg.PPG10games_Diff4 AS Diff4Points10,
	fd.Diff5Games * ppg.PPG10games_Diff5 AS Diff5Points10,
	fd.TotalGames
	INTO #PlayerPredictions
	FROM #PlayerPPG ppg
	INNER JOIN #FixtureDifficulty fd
	ON ppg.PlayerKey = fd.PlayerKey;

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
	)
	SELECT pp.PlayerKey,
	p.PlayerName,
	pa.playerPositionKey,
	t.TeamName AS teamName,
	pp.PredictedPoints,
	pp.PredictedPoints5,
	pp.PredictedPoints10,
	oppg.OverallPPGPredictionPoints,
	(pp.PredictedPoints + pp.PredictedPoints5 + pp.PredictedPoints10 + (oppg.OverallPPGPredictionPoints * @gameweeks)) / 4 AS OverallPrediction,
	(pp.PredictedPointsWeighted + pp.PredictedPoints5Weighted + pp.PredictedPoints10Weighted + oppg.OverallPPGPredictionPointsWeighted) / 110 AS OverallPredictionWeighted,
	pp.TotalGames,
	pp.ChanceOfPlayingNextRound
	FROM PlayerPredictionsWeighted pp
	INNER JOIN OverallPPG oppg
	ON pp.PlayerKey = oppg.PlayerKey
	INNER JOIN dbo.DimPlayer p
	ON pp.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	WHERE pp.ChanceOfPlayingNextRound > 0
	ORDER BY OverallPredictionWeighted DESC;

	IF @debug = 1
	BEGIN

		SELECT @GameweekStart AS GameweekStart, @GameweekEnd AS GameweekEnd, @GameweekStartDate AS GameweekStartDate, @Gameweeks AS Gameweeks

		IF @playerKey IS NULL
		BEGIN

			SELECT '#Fixtures';

			SELECT *
			FROM #Fixtures;

			SELECT '#PPG';

			SELECT *
			FROM #PPG;

			SELECT '#PlayerPPG';

			SELECT *
			FROM #PlayerPPG;

			SELECT '#FixtureDifficulty';

			SELECT *
			FROM #FixtureDifficulty;

			SELECT '#PlayerPredictions';

			SELECT *
			FROM #PlayerPredictions;

		END
		ELSE
		BEGIN

			SELECT '#Fixtures';
			
			SELECT *
			FROM #Fixtures f
			WHERE EXISTS
			(
				SELECT 1
				FROM dbo.DimPlayer
				WHERE PlayerKey = @PlayerKey
				AND (f.TeamKey = teamKey OR f.OpponentTeamKey = teamKey)
			);

			SELECT '#PPG';
			
			SELECT *
			FROM #PPG
			WHERE playerKey = @playerKey;

			SELECT '#PlayerPPG';
			
			SELECT *
			FROM #PlayerPPG
			WHERE playerKey = @playerKey;

			SELECT '#FixtureDifficulty';
			
			SELECT *
			FROM #FixtureDifficulty
			WHERE playerKey = @playerKey;

			SELECT '#PlayerPredictions';
			
			SELECT *
			FROM #PlayerPredictions
			WHERE playerKey = @playerKey;

		END
	END

END