﻿CREATE VIEW dbo.vwGetPlayerPointsStats
--Examples
--EXEC [dbo].[GetPlayerPointsStats];
AS

	WITH PlayerPoints AS
	(
		SELECT ph.PlayerKey,
		t.TeamShortName AS TeamName,
		pp.PlayerPositionShort AS PlayerPosition,
		SUM(ph.TotalPoints) AS PlayerPoints,
		SUM(CASE WHEN ph.[Minutes] >= 60 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsOver60,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		SUM(ph.Assists) AS PlayerAssists,
		SUM(ph.GoalsScored) AS PlayerGoalsScored,
		SUM(ph.CleanSheets) AS PlayerCleanSheets,
		SUM(ph.GoalsConceded) AS PlayerGoalsConceded,
		SUM(ph.Bonus) AS PlayerBonusPoints,
		SUM(CASE WHEN ph.[Minutes] > 0 THEN 1 ELSE 0 END) AS PlayerGames,
		SUM(CASE WHEN ph.[Minutes] >= 60 THEN 1 ELSE 0 END) AS PlayerGamesOver60Min,
		SUM(CASE WHEN ph.[Minutes] > 0 AND gw.SeasonPart = 1 THEN 1 ELSE 0 END) AS PlayerGamesSeasonPart1,
		SUM(CASE WHEN ph.[Minutes] > 0 AND gw.SeasonPart = 2 THEN 1 ELSE 0 END) AS PlayerGamesSeasonPart2,
		SUM(CASE WHEN ph.[Minutes] > 0 AND gw.SeasonPart = 3 THEN 1 ELSE 0 END) AS PlayerGamesSeasonPart3,
		SUM(CASE WHEN ph.[Minutes] > 0 AND gw.SeasonPart = 4 THEN 1 ELSE 0 END) AS PlayerGamesSeasonPart4,
		SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 1 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty1,
		SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 2 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty2,
		SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 3 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty3,
		SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 4 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty4,
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
		GROUP BY ph.PlayerKey, t.TeamShortName, pp.PlayerPositionShort
	)
	SELECT p.PlayerKey,
	p.PlayerName,
	points.PlayerPosition,
	points.TeamName,
	points.PlayerPoints,
	points.PlayerAssists,
	points.PlayerGoalsScored,
	points.PlayerCleanSheets,
	points.PlayerGoalsConceded,
	points.PlayerBonusPoints,
	points.PlayerMinutes,
	points.PlayerGames,
	CAST(ROUND(((points.PlayerGames * 1.00)/38) * 100, 2) AS DECIMAL(6,2)) AS PercGamesPlayed,
	CAST(ROUND(((points.PlayerMinutes * 1.00)/3420) * 100, 2) AS DECIMAL(6,2)) AS PercMinutesPlayed,
	points.PlayerGamesSeasonPart1,
	points.PlayerGamesSeasonPart2,
	points.PlayerGamesSeasonPart3,
	points.PlayerGamesSeasonPart4,
	points.PlayerGamesDifficulty1,
	points.PlayerGamesDifficulty2,
	points.PlayerGamesDifficulty3,
	points.PlayerGamesDifficulty4,
	points.PlayerGamesOver60Min,
	CAST(ROUND(CASE WHEN points.PlayerGames <> 0 THEN (CAST(points.PlayerPoints AS DECIMAL(5,2))/points.PlayerGames) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGame,
	CAST(ROUND(CASE WHEN points.PlayerMinutes <> 0 THEN (CAST(points.PlayerPoints AS DECIMAL(5,2))/points.PlayerMinutes) * 90 ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerExtrapolatedGame,
	CAST(ROUND(CASE WHEN points.PlayerGamesOver60Min <> 0 THEN (CAST(points.PlayerPointsOver60 AS DECIMAL(5,2))/points.PlayerGamesOver60Min) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameOver60min,
	CAST(ROUND(CASE WHEN points.PlayerGamesSeasonPart1 <> 0 THEN (CAST(points.PlayerPointsSeasonPart1 AS DECIMAL(5,2))/points.PlayerGamesSeasonPart1) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart1,
	CAST(ROUND(CASE WHEN points.PlayerGamesSeasonPart2 <> 0 THEN (CAST(points.PlayerPointsSeasonPart2 AS DECIMAL(5,2))/points.PlayerGamesSeasonPart2) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart2,
	CAST(ROUND(CASE WHEN points.PlayerGamesSeasonPart3 <> 0 THEN (CAST(points.PlayerPointsSeasonPart3 AS DECIMAL(5,2))/points.PlayerGamesSeasonPart3) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart3,
	CAST(ROUND(CASE WHEN points.PlayerGamesSeasonPart4 <> 0 THEN (CAST(points.PlayerPointsSeasonPart4 AS DECIMAL(5,2))/points.PlayerGamesSeasonPart4) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameSeasonPart4,
	CAST(ROUND(CASE WHEN points.PlayerGamesDifficulty1 <> 0 THEN (CAST(points.PlayerPointsTeamDifficulty1 AS DECIMAL(5,2))/points.PlayerGamesDifficulty1) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty1,
	CAST(ROUND(CASE WHEN points.PlayerGamesDifficulty2 <> 0 THEN (CAST(points.PlayerPointsTeamDifficulty2 AS DECIMAL(5,2))/points.PlayerGamesDifficulty2) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty2,
	CAST(ROUND(CASE WHEN points.PlayerGamesDifficulty3 <> 0 THEN (CAST(points.PlayerPointsTeamDifficulty3 AS DECIMAL(5,2))/points.PlayerGamesDifficulty3) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty3,
	CAST(ROUND(CASE WHEN points.PlayerGamesDifficulty4 <> 0 THEN (CAST(points.PlayerPointsTeamDifficulty4 AS DECIMAL(5,2))/points.PlayerGamesDifficulty4) ELSE 0 END, 2) AS DECIMAL(6,2)) AS pointsPerGameDifficulty4
	FROM PlayerPoints points
	INNER JOIN dbo.DimPlayer p
	ON p.PlayerKey = points.PlayerKey;