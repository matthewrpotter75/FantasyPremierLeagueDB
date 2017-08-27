CREATE PROCEDURE dbo.GetPlayerPointsStats
--Examples
--EXEC [dbo].[GetPlayerPoints];
AS
BEGIN

	;WITH PlayerPoints AS
	(
		SELECT ph.PlayerKey,
		t.TeamShortName AS TeamName,
		pp.SingularNameShort AS PlayerPosition,
		SUM(ph.TotalPoints) AS PlayerPoints,
		SUM(CASE WHEN ph.[minutes] >= 60 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsOver60,
		SUM(ph.[minutes]) AS playerMinutes,
		SUM(ph.Assists) AS playerAssists,
		SUM(ph.GoalsScored) AS playerGoalsScored,
		SUM(ph.CleanSheets) AS playerCleanSheets,
		SUM(ph.GoalsConceded) AS playerGoalsConceded,
		SUM(ph.Bonus) AS playerBonusPoints,
		SUM(CASE WHEN ph.[minutes] > 0 THEN 1 ELSE 0 END) AS playerGames,
		SUM(CASE WHEN ph.[minutes] >= 60 THEN 1 ELSE 0 END) AS playerGamesOver60Min,
		SUM(CASE WHEN ph.[minutes] > 0 AND gw.SeasonPart = 1 THEN 1 ELSE 0 END) AS playerGamesSeasonPart1,
		SUM(CASE WHEN ph.[minutes] > 0 AND gw.SeasonPart = 2 THEN 1 ELSE 0 END) AS playerGamesSeasonPart2,
		SUM(CASE WHEN ph.[minutes] > 0 AND gw.SeasonPart = 3 THEN 1 ELSE 0 END) AS playerGamesSeasonPart3,
		SUM(CASE WHEN ph.[minutes] > 0 AND gw.SeasonPart = 4 THEN 1 ELSE 0 END) AS playerGamesSeasonPart4,
		SUM(CASE WHEN ph.[minutes] > 0 AND td.Difficulty = 1 THEN 1 ELSE 0 END) AS playerGamesDifficulty1,
		SUM(CASE WHEN ph.[minutes] > 0 AND td.Difficulty = 2 THEN 1 ELSE 0 END) AS playerGamesDifficulty2,
		SUM(CASE WHEN ph.[minutes] > 0 AND td.Difficulty = 3 THEN 1 ELSE 0 END) AS playerGamesDifficulty3,
		SUM(CASE WHEN ph.[minutes] > 0 AND td.Difficulty = 4 THEN 1 ELSE 0 END) AS playerGamesDifficulty4,
		SUM(CASE WHEN gw.SeasonPart = 1 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart1,
		SUM(CASE WHEN gw.SeasonPart = 2 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart2,
		SUM(CASE WHEN gw.SeasonPart = 3 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart3,
		SUM(CASE WHEN gw.SeasonPart = 4 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart4,
		SUM(CASE WHEN td.Difficulty = 1 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty1,
		SUM(CASE WHEN td.Difficulty = 2 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty2,
		SUM(CASE WHEN td.Difficulty = 3 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty3,
		SUM(CASE WHEN td.Difficulty = 4 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty4
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimGameweek gw
		ON ph.GameweekKey = gw.GameweekKey
		AND ph.SeasonKey = gw.SeasonKey
		INNER JOIN dbo.DimTeamDifficulty td
		ON ph.OpponentTeamKey = td.TeamKey
		AND ph.SeasonKey = td.SeasonKey
		AND ph.WasHome = td.IsOpponentHome
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND ph.SeasonKey = pa.SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		GROUP BY ph.playerKey, t.TeamShortName, pp.SingularNameShort
	)
	SELECT p.PlayerKey,
	p.PlayerName,
	points.PlayerPosition,
	points.TeamName,
	points.playerPoints,
	points.playerAssists,
	points.playerGoalsScored,
	points.playerCleanSheets,
	points.playerGoalsConceded,
	points.playerBonusPoints,
	points.playerMinutes,
	points.playerGames,
	CAST(ROUND(((points.playerGames * 1.00)/38) * 100, 2) AS DECIMAL(6,2)) AS PercGamesPlayed,
	CAST(ROUND(((points.playerMinutes * 1.00)/3420) * 100, 2) AS DECIMAL(6,2)) AS PercMinutesPlayed,
	points.playerGamesSeasonPart1,
	points.playerGamesSeasonPart2,
	points.playerGamesSeasonPart3,
	points.playerGamesSeasonPart4,
	points.playerGamesDifficulty1,
	points.playerGamesDifficulty2,
	points.playerGamesDifficulty3,
	points.playerGamesDifficulty4,
	points.playerGamesOver60Min,
	CAST(ROUND(CASE WHEN points.playerGames <> 0 THEN (CAST(points.playerPoints AS DECIMAL(5,2))/points.playerGames) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGame,
	CAST(ROUND(CASE WHEN points.playerMinutes <> 0 THEN (CAST(points.playerPoints AS DECIMAL(5,2))/points.playerMinutes) * 90 ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerExtrapolatedGame,
	CAST(ROUND(CASE WHEN points.playerGamesOver60Min <> 0 THEN (CAST(points.playerPointsOver60 AS DECIMAL(5,2))/points.playerGamesOver60Min) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameOver60min,
	CAST(ROUND(CASE WHEN points.playerGamesSeasonPart1 <> 0 THEN (CAST(points.PlayerPointsSeasonPart1 AS DECIMAL(5,2))/points.playerGamesSeasonPart1) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart1,
	CAST(ROUND(CASE WHEN points.playerGamesSeasonPart2 <> 0 THEN (CAST(points.PlayerPointsSeasonPart2 AS DECIMAL(5,2))/points.playerGamesSeasonPart2) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart2,
	CAST(ROUND(CASE WHEN points.playerGamesSeasonPart3 <> 0 THEN (CAST(points.PlayerPointsSeasonPart3 AS DECIMAL(5,2))/points.playerGamesSeasonPart3) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart3,
	CAST(ROUND(CASE WHEN points.playerGamesSeasonPart4 <> 0 THEN (CAST(points.PlayerPointsSeasonPart4 AS DECIMAL(5,2))/points.playerGamesSeasonPart4) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart4,
	CAST(ROUND(CASE WHEN points.playerGamesDifficulty1 <> 0 THEN (CAST(points.playerPointsTeamDifficulty1 AS DECIMAL(5,2))/points.playerGamesDifficulty1) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty1,
	CAST(ROUND(CASE WHEN points.playerGamesDifficulty2 <> 0 THEN (CAST(points.playerPointsTeamDifficulty2 AS DECIMAL(5,2))/points.playerGamesDifficulty2) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty2,
	CAST(ROUND(CASE WHEN points.playerGamesDifficulty3 <> 0 THEN (CAST(points.playerPointsTeamDifficulty3 AS DECIMAL(5,2))/points.playerGamesDifficulty3) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty3,
	CAST(ROUND(CASE WHEN points.playerGamesDifficulty4 <> 0 THEN (CAST(points.playerPointsTeamDifficulty4 AS DECIMAL(5,2))/points.playerGamesDifficulty4) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty4
	FROM PlayerPoints points
	INNER JOIN dbo.DimPlayer p
	ON p.PlayerKey = points.playerKey
	ORDER BY points.playerPoints DESC;

END