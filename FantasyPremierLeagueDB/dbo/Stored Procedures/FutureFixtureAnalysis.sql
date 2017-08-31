CREATE PROCEDURE dbo.FutureFixtureAnalysis
(
	--DECLARE
	@gameweeks INT = 5,
	@playerPositionId INT,
	@debug BIT = 0,
	@playerId INT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @gameweekStart INT, @gameweekEnd INT, @gameweekStartDate DATE;

	--Get next gameweek
	SELECT @gameweekStart =
	(
		SELECT TOP 1 id
		FROM dbo.Gameweeks
		WHERE deadline_time > GETDATE()
		ORDER BY deadline_time
	);

	SELECT @gameweekStartDate = CAST(deadline_time AS DATE) FROM dbo.Gameweeks WHERE id = @gameweekStart;

	--Get end of gameweek range
	SET @gameweekEnd = @gameweekStart + (@gameweeks - 1);

	--Get list of fixtures in the gameweeks to be analysed
	SELECT gameweekId, difficulty, team_h, team_a, CAST(kickoff_time AS DATE) AS kickoff_date
	INTO #Fixtures
	FROM dbo.Fixtures f
	WHERE f.gameweekId BETWEEN @gameweekStart AND @gameweekEnd;

	--Create temp table with overall points per game
	SELECT p.id AS playerId,
	p.playerPositionId,
	SUM(ph.total_points) AS points,
	COUNT(ph.playerId) AS games,
	SUM(ph.[minutes]) AS [minutes],
	--CASE WHEN SUM(ph.[minutes]) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/SUM(ph.[minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.gameweekId) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/COUNT(ph.gameweekId) ELSE 0 END AS PPG
	INTO #OverallPPG
	FROM dbo.PlayerHistory ph
	INNER JOIN dbo.Players p
	ON ph.playerId = p.id 
	WHERE ph.[minutes] > 45
	AND p.playerPositionId = @playerPositionId
	GROUP BY p.id, p.playerPositionId;

	--Calculate points per game for each player by difficulty of opposition, and whether at home or away
	CREATE TABLE #PPG 
	(
		playerId INT NOT NULL,
		playerPositionId INT NOT NULL,
		difficulty TINYINT NOT NULL,
		was_home BIT NOT NULL,
		points SMALLINT NOT NULL,
		games TINYINT NOT NULL,
		[minutes] SMALLINT NOT NULL,
		PPG DECIMAL(4,2) NOT NULL,
		PPG5games DECIMAL(4,2),
		PPG10games DECIMAL(4,2)
	);

	INSERT INTO #PPG
	(playerId, playerPositionId, difficulty, was_home, points, games, [minutes], PPG)
	SELECT p.id AS playerId,
	p.playerPositionId,
	d.difficulty,
	ph.was_home,
	SUM(ph.total_points) AS points,
	COUNT(ph.playerId) AS games,
	SUM(ph.[minutes]) AS [minutes],
	--CASE WHEN SUM(ph.[minutes]) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/SUM(ph.[minutes]) * 90 ELSE 0 END AS PPG
	CASE WHEN COUNT(ph.gameweekId) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/COUNT(ph.gameweekId) ELSE 0 END AS PPG
	FROM dbo.PlayerHistory ph
	INNER JOIN dbo.Players p
	ON ph.playerId = p.id 
	INNER JOIN dbo.Difficulty d
	ON ph.opponent_teamId = d.teamId
	AND ph.was_home = d.is_opponent_home
	WHERE ph.[minutes] > 45
	AND p.playerPositionId = @playerPositionId
	GROUP BY p.id, p.playerPositionId, d.difficulty, ph.was_home;

	;WITH PlayerHistoryRanked AS
	(
		SELECT playerId,
		gameweekId,
		ROW_NUMBER() OVER (PARTITION BY playerId ORDER BY gameweekId DESC) AS gameweekInc,
		total_points,
		[minutes],
		was_home,
		opponent_teamId
		FROM dbo.PlayerHistory
		WHERE [minutes] > 45
	)
	,PlayerHistory5 AS
	(
		SELECT ph.playerId,
		p.playerPositionId,
		d.difficulty,
		ph.was_home,
		SUM(ph.total_points) AS points,
		COUNT(ph.playerId) AS games,
		SUM(ph.[minutes]) AS [minutes],
		--CASE WHEN SUM(ph.[minutes]) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/SUM(ph.[minutes]) * 90 ELSE 0 END AS PPG5
		CASE WHEN COUNT(ph.gameweekId) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/COUNT(ph.gameweekId) ELSE 0 END AS PPG5
		FROM PlayerHistoryRanked ph
		INNER JOIN dbo.Players p
		ON ph.playerId = p.id 
		INNER JOIN dbo.Difficulty d
		ON ph.opponent_teamId = d.teamId
		AND ph.was_home = d.is_opponent_home
		WHERE ph.[minutes] > 45
		--AND ph.gameweekId BETWEEN (@gameweekStart - 5) AND @gameweekStart
		AND ph.gameweekInc BETWEEN 1 AND 5
		AND p.playerPositionId = @playerPositionId
		GROUP BY ph.playerId, p.playerPositionId, d.difficulty, ph.was_home
	)
	UPDATE #PPG
	SET PPG5games = ph5.PPG5
	FROM #PPG ppg
	INNER JOIN PlayerHistory5 ph5
	ON ppg.playerId = ph5.playerId
	AND ppg.playerPositionId = ph5.playerPositionId
	AND ppg.difficulty = ph5.difficulty
	AND ppg.was_home = ph5.was_home;

	;WITH PlayerHistoryRanked AS
	(
		SELECT playerId,
		gameweekId,
		ROW_NUMBER() OVER (PARTITION BY playerId ORDER BY gameweekId DESC) AS gameweekInc,
		total_points,
		[minutes],
		was_home,
		opponent_teamId
		FROM dbo.PlayerHistory
		WHERE [minutes] > 45
	)
	,PlayerHistory10 AS
	(
		SELECT ph.playerId,
		p.playerPositionId,
		d.difficulty,
		ph.was_home,
		SUM(ph.total_points) AS points,
		COUNT(ph.playerId) AS games,
		SUM(ph.[minutes]) AS [minutes],
		--CASE WHEN SUM(ph.[minutes]) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/SUM(ph.[minutes]) * 90 ELSE 0 END AS PPG10
		CASE WHEN COUNT(ph.gameweekId) <> 0 THEN SUM(CAST(ph.total_points AS decimal(8,6)))/COUNT(ph.gameweekId) ELSE 0 END AS PPG10
		FROM PlayerHistoryRanked ph
		INNER JOIN dbo.Players p
		ON ph.playerId = p.id 
		INNER JOIN dbo.Difficulty d
		ON ph.opponent_teamId = d.teamId
		AND ph.was_home = d.is_opponent_home
		WHERE ph.[minutes] > 45
		--AND ph.gameweekId BETWEEN (@gameweekStart - 10) AND @gameweekStart
		AND ph.gameweekInc BETWEEN 1 AND 10
		AND p.playerPositionId = @playerPositionId
		GROUP BY ph.playerId, p.playerPositionId, d.difficulty, ph.was_home
	)
	UPDATE #PPG
	SET PPG10games = ph10.PPG10
	FROM #PPG ppg
	INNER JOIN PlayerHistory10 ph10
	ON ppg.playerId = ph10.playerId
	AND ppg.playerPositionId = ph10.playerPositionId
	AND ppg.difficulty = ph10.difficulty
	AND ppg.was_home = ph10.was_home;

	UPDATE #PPG
	SET PPG5games = 0
	WHERE PPG5games IS NULL;

	UPDATE #PPG
	SET PPG10games = 0
	WHERE PPG10games IS NULL;

	--Aggregate to get one row per player (there will only be one row per difficulty so not really aggregation)
	SELECT playerId, 
	playerPositionId,
	SUM(CASE WHEN difficulty = 1 THEN PPG ELSE 0 END) AS PPG_Diff1,
	SUM(CASE WHEN difficulty = 1 THEN PPG5games ELSE 0 END) AS PPG5games_Diff1,
	SUM(CASE WHEN difficulty = 1 THEN PPG10games ELSE 0 END) AS PPG10games_Diff1,
	SUM(CASE WHEN difficulty = 2 THEN PPG ELSE 0 END) AS PPG_Diff2,
	SUM(CASE WHEN difficulty = 2 THEN PPG5games ELSE 0 END) AS PPG5games_Diff2,
	SUM(CASE WHEN difficulty = 2 THEN PPG10games ELSE 0 END) AS PPG10games_Diff2,
	SUM(CASE WHEN difficulty = 3 THEN PPG ELSE 0 END) AS PPG_Diff3,
	SUM(CASE WHEN difficulty = 3 THEN PPG5games ELSE 0 END) AS PPG5games_Diff3,
	SUM(CASE WHEN difficulty = 3 THEN PPG10games ELSE 0 END) AS PPG10games_Diff3,
	SUM(CASE WHEN difficulty = 4 THEN PPG ELSE 0 END) AS PPG_Diff4,
	SUM(CASE WHEN difficulty = 4 THEN PPG5games ELSE 0 END) AS PPG5games_Diff4,
	SUM(CASE WHEN difficulty = 4 THEN PPG10games ELSE 0 END) AS PPG10games_Diff4,
	SUM(CASE WHEN difficulty = 5 THEN PPG ELSE 0 END) AS PPG_Diff5,
	SUM(CASE WHEN difficulty = 5 THEN PPG5games ELSE 0 END) AS PPG5games_Diff5,
	SUM(CASE WHEN difficulty = 5 THEN PPG10games ELSE 0 END) AS PPG10games_Diff5
	INTO #PlayerPPG
	FROM #PPG
	GROUP BY playerId, playerPositionId
	ORDER BY playerId, playerPositionId;

	--Get the difficulty of upcoming fixtures for each player
	CREATE TABLE #FixtureDifficulty 
	(
		playerId INT NOT NULL,
		diff1_games INT NOT NULL,
		diff2_games INT NOT NULL,
		diff3_games INT NOT NULL,
		diff4_games INT NOT NULL,
		diff5_games INT NOT NULL,
		total_games INT NOT NULL,
		is_home BIT NOT NULL
	);

	;WITH players AS
	(
		SELECT id, 
		teamId,
		CASE 
			WHEN ISNULL(news,'') <> '' AND CHARINDEX('Unknown return date', news) = 0 AND [status] IN ('i','s') THEN CAST(REVERSE(LEFT(REVERSE(news), CHARINDEX(' ', REVERSE(news), CHARINDEX(' ',REVERSE(news))+1)-1))+ CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
			ELSE @gameweekStartDate
		END AS startDate
		FROM dbo.Players
		WHERE playerPositionId = @playerPositionId
	)
	INSERT INTO #FixtureDifficulty
	(playerId, diff1_games, diff2_games, diff3_games, diff4_games, diff5_games, total_games, is_home)
	SELECT p.id AS playerId,
	SUM(CASE WHEN f.difficulty = 1 THEN 1 ELSE 0 END) AS diff1_games,
	SUM(CASE WHEN f.difficulty = 2 THEN 1 ELSE 0 END) AS diff2_games,
	SUM(CASE WHEN f.difficulty = 3 THEN 1 ELSE 0 END) AS diff3_games,
	SUM(CASE WHEN f.difficulty = 4 THEN 1 ELSE 0 END) AS diff4_games,
	SUM(CASE WHEN f.difficulty = 5 THEN 1 ELSE 0 END) AS diff5_games,
	COUNT(1) AS total_games,
	1 AS is_home
	FROM #Fixtures f
	INNER JOIN players p
	ON f.team_h = p.teamId
	WHERE f.gameweekId BETWEEN @gameweekStart AND @gameweekEnd
	AND f.kickoff_date >= p.startDate
	GROUP BY p.id

	UNION

	SELECT p.id AS playerId,
	SUM(CASE WHEN f.difficulty = 1 THEN 1 ELSE 0 END) AS diff1_games,
	SUM(CASE WHEN f.difficulty = 2 THEN 1 ELSE 0 END) AS diff2_games,
	SUM(CASE WHEN f.difficulty = 3 THEN 1 ELSE 0 END) AS diff3_games,
	SUM(CASE WHEN f.difficulty = 4 THEN 1 ELSE 0 END) AS diff4_games,
	SUM(CASE WHEN f.difficulty = 5 THEN 1 ELSE 0 END) AS diff5_games,
	COUNT(1) AS total_games,
	0 AS is_home
	FROM #Fixtures f
	INNER JOIN players p
	ON f.team_a = p.teamId
	WHERE f.gameweekId BETWEEN @gameweekStart AND @gameweekEnd
	AND f.kickoff_date >= p.startDate
	GROUP BY p.id

	ORDER BY p.id;

	--Multiply the points per game for each difficulty level by the number of games for that difficulty
	SELECT ppg.playerId,
	fd.diff1_games * ppg.PPG_Diff1 AS Diff1Points,
	fd.diff2_games * ppg.PPG_Diff2 AS Diff2Points,
	fd.diff3_games * ppg.PPG_Diff3 AS Diff3Points,
	fd.diff4_games * ppg.PPG_Diff4 AS Diff4Points,
	fd.diff5_games * ppg.PPG_Diff5 AS Diff5Points,

	fd.diff1_games * ppg.PPG5games_Diff1 AS Diff1Points5,
	fd.diff2_games * ppg.PPG5games_Diff2 AS Diff2Points5,
	fd.diff3_games * ppg.PPG5games_Diff3 AS Diff3Points5,
	fd.diff4_games * ppg.PPG5games_Diff4 AS Diff4Points5,
	fd.diff5_games * ppg.PPG5games_Diff5 AS Diff5Points5,

	fd.diff1_games * ppg.PPG10games_Diff1 AS Diff1Points10,
	fd.diff2_games * ppg.PPG10games_Diff2 AS Diff2Points10,
	fd.diff3_games * ppg.PPG10games_Diff3 AS Diff3Points10,
	fd.diff4_games * ppg.PPG10games_Diff4 AS Diff4Points10,
	fd.diff5_games * ppg.PPG10games_Diff5 AS Diff5Points10,
	fd.total_games
	INTO #PlayerPredictions
	FROM #PlayerPPG ppg
	INNER JOIN #FixtureDifficulty fd
	ON ppg.playerId = fd.playerId;

	;WITH PlayerPredictions AS
	(
		SELECT playerId,
		SUM(Diff1Points + Diff2Points + Diff3Points + Diff4Points + Diff5Points) AS PredictedPoints,
		SUM(Diff1Points5 + Diff2Points5 + Diff3Points5 + Diff4Points5 + Diff5Points5) AS PredictedPoints5,
		SUM(Diff1Points10 + Diff2Points10 + Diff3Points10 + Diff4Points10 + Diff5Points10) AS PredictedPoints10,
		SUM(total_games) AS total_games
		FROM #PlayerPredictions
		GROUP BY playerId
	),
	PlayerPredictionsWeighted AS
	(
		SELECT playerId,
		PredictedPoints,
		PredictedPoints5,
		PredictedPoints10,
		(PredictedPoints * 5) AS PredictedPointsWeighted,
		(PredictedPoints5 * 3) AS PredictedPoints5Weighted,
		(PredictedPoints10 * 2) AS PredictedPoints10Weighted,
		total_games
		FROM PlayerPredictions
	),
	OverallPPG AS
	(
		SELECT playerId,
		PPG * @gameweeks AS OverallPPGPredictionPoints,
		PPG * @gameweeks * 100 AS OverallPPGPredictionPointsWeighted
		FROM #OverallPPG
	)
	SELECT pp.playerId,
	p.first_name + ' ' + p.second_name AS playerName,
	p.playerPositionId,
	t.name AS teamName,
	pp.PredictedPoints,
	pp.PredictedPoints5,
	pp.PredictedPoints10,
	oppg.OverallPPGPredictionPoints,
	(pp.PredictedPoints + pp.PredictedPoints5 + pp.PredictedPoints10 + (oppg.OverallPPGPredictionPoints * @gameweeks)) / 4 AS OverallPrediction,
	(pp.PredictedPointsWeighted + pp.PredictedPoints5Weighted + pp.PredictedPoints10Weighted + oppg.OverallPPGPredictionPointsWeighted) / 110 AS OverallPredictionWeighted,
	pp.total_games,
	p.chance_of_playing_next_round
	FROM PlayerPredictionsWeighted pp
	INNER JOIN OverallPPG oppg
	ON pp.playerId = oppg.playerId
	INNER JOIN dbo.Players p
	ON pp.playerId = p.id
	INNER JOIN dbo.Teams t
	ON p.teamId = t.id
	WHERE p.chance_of_playing_next_round > 0
	ORDER BY OverallPredictionWeighted DESC;

	IF @debug = 1
	BEGIN

		SELECT @gameweekStart AS gameweekStart, @gameweekEnd AS gameweekEnd, @gameweekStartDate AS gameweekStartDate, @gameweeks AS gameweeks

		IF @playerId IS NULL
		BEGIN

			SELECT *
			FROM #Fixtures;

			SELECT *
			FROM #PPG;

			SELECT *
			FROM #PlayerPPG;

			SELECT *
			FROM #FixtureDifficulty;

			SELECT *
			FROM #PlayerPredictions;

		END
		ELSE
		BEGIN

			SELECT *
			FROM #Fixtures f
			WHERE EXISTS
			(
				SELECT 1
				FROM dbo.Players
				WHERE id = @playerId
				AND (f.team_h = teamId OR f.team_a = teamId)
			)

			SELECT *
			FROM #PPG
			WHERE playerId = @playerId;

			SELECT *
			FROM #PlayerPPG
			WHERE playerId = @playerId;

			SELECT *
			FROM #FixtureDifficulty
			WHERE playerId = @playerId;

			SELECT *
			FROM #PlayerPredictions
			WHERE playerId = @playerId;

		END
	END

END