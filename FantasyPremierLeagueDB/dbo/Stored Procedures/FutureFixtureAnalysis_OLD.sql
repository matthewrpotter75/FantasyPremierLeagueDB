USE [FantasyPremierLeague]
GO

/****** Object:  StoredProcedure [dbo].[FutureFixtureAnalysis]    Script Date: 14/04/2017 00:54:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[FutureFixtureAnalysis]
(
	--DECLARE
	@gameweeks INT = 5,
	@playerPositionId INT,
	@Debug BIT = 0
)
AS
BEGIN

	DECLARE @gameweekStart INT, @gameweekEnd INT;

	--Get next gameweek
	SELECT @gameweekStart =
	(SELECT TOP 1 gameweekId
	FROM dbo.Fixtures
	WHERE gameweekId IS NOT NULL
	ORDER BY gameweekId);

	--Get end of gameweek range
	SET @gameweekEnd = @gameweekStart + (@gameweeks - 1);

	SELECT gameweekId, difficulty, team_h, team_a
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
		AND ph.gameweekId BETWEEN (@gameweekStart - 5) AND @gameweekStart
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
		AND ph.gameweekId BETWEEN (@gameweekStart - 10) AND @gameweekStart
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
		is_home BIT NOT NULL
	);

	INSERT INTO #FixtureDifficulty
	(playerId, diff1_games, diff2_games, diff3_games, diff4_games, diff5_games, is_home)
	SELECT p.id AS playerId,
	SUM(CASE WHEN f.difficulty = 1 THEN 1 ELSE 0 END) AS diff1_games,
	SUM(CASE WHEN f.difficulty = 2 THEN 1 ELSE 0 END) AS diff2_games,
	SUM(CASE WHEN f.difficulty = 3 THEN 1 ELSE 0 END) AS diff3_games,
	SUM(CASE WHEN f.difficulty = 4 THEN 1 ELSE 0 END) AS diff4_games,
	SUM(CASE WHEN f.difficulty = 5 THEN 1 ELSE 0 END) AS diff5_games,
	1 AS is_home
	FROM #Fixtures f
	INNER JOIN dbo.Players p
	ON f.team_h = p.teamId
	WHERE f.gameweekId BETWEEN @gameweekStart AND @gameweekEnd
	AND p.playerPositionId = @playerPositionId
	GROUP BY p.id

	UNION

	SELECT p.id AS playerId,
	SUM(CASE WHEN f.difficulty = 1 THEN 1 ELSE 0 END) AS diff1_games,
	SUM(CASE WHEN f.difficulty = 2 THEN 1 ELSE 0 END) AS diff2_games,
	SUM(CASE WHEN f.difficulty = 3 THEN 1 ELSE 0 END) AS diff3_games,
	SUM(CASE WHEN f.difficulty = 4 THEN 1 ELSE 0 END) AS diff4_games,
	SUM(CASE WHEN f.difficulty = 5 THEN 1 ELSE 0 END) AS diff5_games,
	0 AS is_home
	FROM #Fixtures f
	INNER JOIN dbo.Players p
	ON f.team_a = p.teamId
	WHERE f.gameweekId BETWEEN @gameweekStart AND @gameweekEnd
	AND p.playerPositionId = @playerPositionId
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
	fd.diff5_games * ppg.PPG10games_Diff5 AS Diff5Points10
	INTO #PlayerPredictions
	FROM #PlayerPPG ppg
	INNER JOIN #FixtureDifficulty fd
	ON ppg.playerId = fd.playerId;

	;WITH PlayerPredictions AS
	(
		SELECT pp.playerId,
		SUM(pp.Diff1Points + pp.Diff2Points + pp.Diff3Points + pp.Diff4Points + pp.Diff5Points) AS PredictedPoints,
		SUM(pp.Diff1Points5 + pp.Diff2Points5 + pp.Diff3Points5 + pp.Diff4Points5 + pp.Diff5Points5) AS PredictedPoints5,
		SUM(pp.Diff1Points10 + pp.Diff2Points10 + pp.Diff3Points10 + pp.Diff4Points10 + pp.Diff5Points10) AS PredictedPoints10
		FROM #PlayerPredictions pp
		GROUP BY pp.playerId
	)
	SELECT pp.playerId,
	p.first_name + ' ' + p.second_name AS playerName,
	p.playerPositionId,
	t.name AS teamName,
	pp.PredictedPoints,
	pp.PredictedPoints5,
	pp.PredictedPoints10
	FROM PlayerPredictions pp
	INNER JOIN dbo.Players p
	ON pp.playerId = p.id
	INNER JOIN dbo.Teams t
	ON p.teamId = t.id
	WHERE p.[status] IN ('a','d')
	--WHERE playerPositionId = @playerPositionId
	ORDER BY PredictedPoints DESC;

	IF @Debug = 1
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

END
GO


