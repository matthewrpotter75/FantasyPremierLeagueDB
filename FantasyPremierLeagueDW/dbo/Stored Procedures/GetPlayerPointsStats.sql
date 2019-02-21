CREATE PROCEDURE dbo.GetPlayerPointsStats
(
	@SeasonKey INT
)
AS
BEGIN

	SET NOCOUNT ON;

	--Get the total games each team has played in the season
	SELECT tr.TeamKey,
	COUNT(1) AS NumberOfMatches
	INTO #TeamMatches
	FROM dbo.FactTeamResults tr
	WHERE tr.SeasonKey = @SeasonKey
	GROUP BY tr.TeamKey;

	--Aggregate counts based on minutes and gameweeks to player, team, and player position
	SELECT 
	ph.PlayerKey,
	t.TeamKey, 
	pp.PlayerPositionKey,
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
	SUM(CASE WHEN gw.SeasonPart = 1 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart1,
	SUM(CASE WHEN gw.SeasonPart = 2 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart2,
	SUM(CASE WHEN gw.SeasonPart = 3 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart3,
	SUM(CASE WHEN gw.SeasonPart = 4 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsSeasonPart4
	INTO #PlayerPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimGameweek gw
	ON ph.GameweekKey = gw.GameweekKey
	AND ph.SeasonKey = gw.SeasonKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON ph.PlayerKey = pa.PlayerKey
	AND ph.SeasonKey = pa.SeasonKey
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	WHERE ph.SeasonKey = @SeasonKey
	GROUP BY ph.PlayerKey, t.TeamKey, pp.PlayerPositionKey;

	--Aggregate counts based on team difficulty to player, team, and player position
	SELECT 
	ph.PlayerKey,
	t.TeamKey, 
	pp.PlayerPositionKey,
	SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 1 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty1,
	SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 2 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty2,
	SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 3 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty3,
	SUM(CASE WHEN ph.[Minutes] > 0 AND td.Difficulty = 4 THEN 1 ELSE 0 END) AS PlayerGamesDifficulty4,
	SUM(CASE WHEN td.Difficulty = 1 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty1,
	SUM(CASE WHEN td.Difficulty = 2 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty2,
	SUM(CASE WHEN td.Difficulty = 3 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty3,
	SUM(CASE WHEN td.Difficulty = 4 THEN ph.TotalPoints ELSE 0 END) AS PlayerPointsTeamDifficulty4
	INTO #PlayerDifficulty
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayerAttribute pa
	ON ph.PlayerKey = pa.PlayerKey
	AND ph.SeasonKey = pa.SeasonKey
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.SeasonKey = td.SeasonKey
	AND ph.WasHome = td.IsOpponentHome
	WHERE ph.SeasonKey = @SeasonKey
	GROUP BY ph.PlayerKey, t.TeamKey, pp.PlayerPositionKey;

	--Join the two previous temp tables together for final output
	SELECT p.PlayerKey,
	p.PlayerName,
	dpp.PlayerPosition,
	t.TeamName,
	pp.PlayerPoints,
	pp.PlayerAssists,
	pp.PlayerGoalsScored,
	pp.PlayerCleanSheets,
	pp.PlayerGoalsConceded,
	pp.PlayerBonusPoints,
	pp.PlayerMinutes,
	pp.PlayerGames,
	CAST(ROUND(((pp.PlayerGames * 1.00)/tm.NumberOfMatches) * 100, 2) AS DECIMAL(6,2)) AS PercGamesPlayed,
	CAST(ROUND(((pp.PlayerMinutes * 1.00)/(tm.NumberOfMatches * 90)) * 100, 2) AS DECIMAL(6,2)) AS PercMinutesPlayed,
	CAST(ROUND(((pp.PlayerGamesOver60Min * 1.00)/tm.NumberOfMatches) * 100, 2) AS DECIMAL(6,2)) AS PercGamesStarted,
	pp.PlayerGamesSeasonPart1,
	pp.PlayerGamesSeasonPart2,
	pp.PlayerGamesSeasonPart3,
	pp.PlayerGamesSeasonPart4,
	pd.PlayerGamesDifficulty1,
	pd.PlayerGamesDifficulty2,
	pd.PlayerGamesDifficulty3,
	pd.PlayerGamesDifficulty4,
	pp.PlayerGamesOver60Min,
	CAST(ROUND(CASE WHEN pp.PlayerGames <> 0 THEN (CAST(pp.PlayerPoints AS DECIMAL(5,2))/pp.PlayerGames) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGame,
	CAST(ROUND(CASE WHEN pp.PlayerMinutes <> 0 THEN (CAST(pp.PlayerPoints AS DECIMAL(5,2))/pp.PlayerMinutes) * 90 ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerExtrapolatedGame,
	CAST(ROUND(CASE WHEN pp.PlayerGamesOver60Min <> 0 THEN (CAST(pp.PlayerPointsOver60 AS DECIMAL(5,2))/pp.PlayerGamesOver60Min) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameOver60min,
	CAST(ROUND(CASE WHEN pp.PlayerGamesSeasonPart1 <> 0 THEN (CAST(pp.PlayerPointsSeasonPart1 AS DECIMAL(5,2))/pp.PlayerGamesSeasonPart1) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameSeasonPart1,
	CAST(ROUND(CASE WHEN pp.PlayerGamesSeasonPart2 <> 0 THEN (CAST(pp.PlayerPointsSeasonPart2 AS DECIMAL(5,2))/pp.PlayerGamesSeasonPart2) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameSeasonPart2,
	CAST(ROUND(CASE WHEN pp.PlayerGamesSeasonPart3 <> 0 THEN (CAST(pp.PlayerPointsSeasonPart3 AS DECIMAL(5,2))/pp.PlayerGamesSeasonPart3) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameSeasonPart3,
	CAST(ROUND(CASE WHEN pp.PlayerGamesSeasonPart4 <> 0 THEN (CAST(pp.PlayerPointsSeasonPart4 AS DECIMAL(5,2))/pp.PlayerGamesSeasonPart4) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameSeasonPart4,
	CAST(ROUND(CASE WHEN pd.PlayerGamesDifficulty1 <> 0 THEN (CAST(pd.PlayerPointsTeamDifficulty1 AS DECIMAL(5,2))/pd.PlayerGamesDifficulty1) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameDifficulty1,
	CAST(ROUND(CASE WHEN pd.PlayerGamesDifficulty2 <> 0 THEN (CAST(pd.PlayerPointsTeamDifficulty2 AS DECIMAL(5,2))/pd.PlayerGamesDifficulty2) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameDifficulty2,
	CAST(ROUND(CASE WHEN pd.PlayerGamesDifficulty3 <> 0 THEN (CAST(pd.PlayerPointsTeamDifficulty3 AS DECIMAL(5,2))/pd.PlayerGamesDifficulty3) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameDifficulty3,
	CAST(ROUND(CASE WHEN pd.PlayerGamesDifficulty4 <> 0 THEN (CAST(pd.PlayerPointsTeamDifficulty4 AS DECIMAL(5,2))/pd.PlayerGamesDifficulty4) ELSE 0 END, 2) AS DECIMAL(6,2)) AS PointsPerGameDifficulty4
	FROM #PlayerPoints pp
	INNER JOIN #PlayerDifficulty pd
	ON pp.PlayerKey = pd.PlayerKey
	AND pp.TeamKey = pd.TeamKey
	AND pp.PlayerPositionKey = pd.PlayerPositionKey
	INNER JOIN dbo.DimPlayer p
	ON pp.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerPosition dpp
	ON pp.PlayerPositionKey = dpp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pp.TeamKey = t.TeamKey
	INNER JOIN #TeamMatches tm
	ON pp.TeamKey = tm.TeamKey
	ORDER BY pp.PlayerPoints DESC;

END;