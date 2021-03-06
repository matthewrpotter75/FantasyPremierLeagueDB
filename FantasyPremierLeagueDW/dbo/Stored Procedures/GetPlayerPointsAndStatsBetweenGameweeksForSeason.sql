CREATE PROCEDURE dbo.GetPlayerPointsAndStatsBetweenGameweeksForSeason
(
	@SeasonKey INT,
	@GameweekStart INT = 1,
	@GameweekEnd INT = 38,
	@PlayerPositionKey INT = NULL,
	@TeamKey INT = NULL,
	@MaxCost INT = 200,
	@ComparisonPreviousGameweeks INT = 10,
	@OrderBy INT = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PreviousComparisonGameweekStart INT;

	IF @GameweekEnd - @ComparisonPreviousGameweeks > 1
	BEGIN
		SELECT @PreviousComparisonGameweekStart = @GameweekStart - @ComparisonPreviousGameweeks
	END
	ELSE
	BEGIN
		SELECT @PreviousComparisonGameweekStart = 1;
	END

	;WITH PreviousGameweekComparison AS
	(
		SELECT p.PlayerKey, 
			COUNT(1) AS TotalGames, 
			SUM(ph.[Minutes]) AS TotalMinutes, 
			SUM(ph.TotalPoints) AS TotalPoints, 
			CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS PPG, 
			CASE WHEN SUM(ph.TotalPoints) <> 0
				THEN CAST(SUM(ph.[Minutes] * 1.00)/SUM(ph.TotalPoints) AS DECIMAL(5,2))
				ELSE 0
			END AS MinsPerPoint
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON ph.PlayerKey = pcs.PlayerKey
		WHERE ph.SeasonKey = @SeasonKey
		AND
		(
			pa.PlayerPositionKey = @PlayerPositionKey
			OR
			@PlayerPositionKey IS NULL
		)
		AND
		(
			pa.TeamKey = @TeamKey
			OR
			@TeamKey IS NULL
		)
		AND pcs.Cost <= @MaxCost
		AND ph.GameweekKey >= @PreviousComparisonGameweekStart
		AND ph.GameweekKey <= @GameweekEnd
		GROUP BY p.PlayerKey

	),
	SeasonComparison AS
	(
		SELECT p.PlayerKey, 
			COUNT(1) AS TotalGames, 
			SUM(ph.[Minutes]) AS TotalMinutes, 
			SUM(ph.TotalPoints) AS TotalPoints, 
			CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS PPG, 
			CASE WHEN SUM(ph.TotalPoints) <> 0
				THEN CAST(SUM(ph.[Minutes] * 1.00)/SUM(ph.TotalPoints) AS DECIMAL(5,2))
				ELSE 0
			END AS MinsPerPoint,
			SUM(ph.Saves) AS Saves,
			SUM(ph.PenaltiesSaved) AS PenaltiesSaved,
			SUM(ph.CleanSheets) AS CleanSheets,
			SUM(ph.GoalsConceded) AS GoalsConceded,
			SUM(ph.Tackles) AS Tackles,
			SUM(ph.Tackled) AS Tackled,
			SUM(ph.Fouls) AS Fouls,
			SUM(ph.ClearancesBlocksInterceptions) AS ClearancesBlocksInterceptions,
			SUM(ph.ErrorsLeadingToGoalAttempt) AS ErrorsLeadingToGoalAttempt,
			SUM(ph.ErrorsLeadingToGoal) AS ErrorsLeadingToGoal,
			SUM(ph.PenaltiesConceded) AS PenaltiesConceded,
			SUM(ph.OwnGoals) AS OwnGoals,
			SUM(ph.Recoveries) AS Recoveries,
			SUM(ph.AttemptedPasses) AS AttemptedPasses,
			SUM(ph.CompletedPasses) AS CompletedPasses,
			SUM(ph.KeyPasses) AS KeyPasses,
			SUM(ph.BigChancesCreated) AS BigChancesCreated,
			SUM(ph.OpenPlayCrosses) AS OpenPlayCrosses,
			SUM(ph.Dribbles) AS Dribbles,
			SUM(ph.Assists) AS Assists,
			SUM(ph.GoalsScored) AS GoalsScored,
			SUM(ph.TargetMissed) AS TargetMissed,
			SUM(ph.PenaltiesMissed) AS PenaltiesMissed,
			SUM(ph.BigChancesMissed) AS BigChancesMissed,
			SUM(ph.Offside) AS Offside
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON ph.PlayerKey = pcs.PlayerKey
		WHERE ph.SeasonKey = @SeasonKey
		AND
		(
			pa.PlayerPositionKey = @PlayerPositionKey
			OR
			@PlayerPositionKey IS NULL
		)
		AND
		(
			pa.TeamKey = @TeamKey
			OR
			@TeamKey IS NULL
		)
		AND pcs.Cost <= @MaxCost
		AND ph.GameweekKey <= @GameweekEnd
		GROUP BY p.PlayerKey
	),
	CurrentGameweekSelection AS
	(
		SELECT p.PlayerKey, 
			p.PlayerName, 
			pp.PlayerPositionShort AS PlayerPosition, 
			t.TeamShortName AS TeamName, 
			pcs.Cost, 
			COUNT(1) AS SelectionGames, 
			SUM(ph.[Minutes]) AS SelectionMinutes, 
			SUM(ph.TotalPoints) AS SelectionPoints, 
			CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS PPG, 
			CASE WHEN SUM(ph.TotalPoints) <> 0
				THEN CAST(SUM(ph.[Minutes] * 1.00)/SUM(ph.TotalPoints) AS DECIMAL(5,2))
				ELSE 0
			END AS MinsPerPoint,
			SUM(ph.Saves) AS Saves,
			SUM(ph.PenaltiesSaved) AS PenaltiesSaved,
			SUM(ph.CleanSheets) AS CleanSheets,
			SUM(ph.GoalsConceded) AS GoalsConceded,
			SUM(ph.Tackles) AS Tackles,
			SUM(ph.Tackled) AS Tackled,
			SUM(ph.Fouls) AS Fouls,
			SUM(ph.ClearancesBlocksInterceptions) AS ClearancesBlocksInterceptions,
			SUM(ph.ErrorsLeadingToGoalAttempt) AS ErrorsLeadingToGoalAttempt,
			SUM(ph.ErrorsLeadingToGoal) AS ErrorsLeadingToGoal,
			SUM(ph.PenaltiesConceded) AS PenaltiesConceded,
			SUM(ph.OwnGoals) AS OwnGoals,
			SUM(ph.Recoveries) AS Recoveries,
			SUM(ph.AttemptedPasses) AS AttemptedPasses,
			SUM(ph.CompletedPasses) AS CompletedPasses,
			SUM(ph.KeyPasses) AS KeyPasses,
			SUM(ph.BigChancesCreated) AS BigChancesCreated,
			SUM(ph.OpenPlayCrosses) AS OpenPlayCrosses,
			SUM(ph.Dribbles) AS Dribbles,
			SUM(ph.Assists) AS Assists,
			SUM(ph.GoalsScored) AS GoalsScored,
			SUM(ph.TargetMissed) AS TargetMissed,
			SUM(ph.PenaltiesMissed) AS PenaltiesMissed,
			SUM(ph.BigChancesMissed) AS BigChancesMissed,
			SUM(ph.Offside) AS Offside
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		INNER JOIN dbo.DimTeam ot
		ON ph.OpponentTeamKey = ot.TeamKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON ph.PlayerKey = pcs.PlayerKey
		WHERE ph.SeasonKey = @SeasonKey
		AND
		(
			pa.PlayerPositionKey = @PlayerPositionKey
			OR
			@PlayerPositionKey IS NULL
		)
		AND
		(
			pa.TeamKey = @TeamKey
			OR
			@TeamKey IS NULL
		)
		AND pcs.Cost <= @MaxCost
		AND ph.GameweekKey >= @GameweekStart
		AND ph.GameweekKey <= @GameweekEnd
		GROUP BY p.PlayerKey, p.PlayerName, pp.PlayerPositionShort, t.TeamShortName, pcs.Cost
	)
	--SELECT cgs.*,
	SELECT cgs.PlayerKey, 
		cgs.PlayerName, 
		cgs.PlayerPosition, 
		cgs.TeamName, 
		cgs.Cost,
		sc.TotalGames,
		sc.TotalMinutes,
		sc.TotalPoints,
		cgs.SelectionGames, 
		cgs.SelectionMinutes, 
		cgs.SelectionPoints, 
		CAST(cgs.Saves AS VARCHAR(100)) + ' (' + CAST(sc.Saves AS VARCHAR(100)) + ')' AS Saves,
		CAST(cgs.PenaltiesSaved AS VARCHAR(100)) + ' (' + CAST(sc.PenaltiesSaved AS VARCHAR(100)) + ')' AS PenaltiesSaved,
		CAST(cgs.CleanSheets AS VARCHAR(100)) + ' (' + CAST(sc.CleanSheets AS VARCHAR(100)) + ')' AS CleanSheets,
		CAST(cgs.GoalsConceded AS VARCHAR(100)) + ' (' + CAST(sc.GoalsConceded AS VARCHAR(100)) + ')' AS GoalsConceded,
		CAST(cgs.Tackles AS VARCHAR(100)) + ' (' + CAST(sc.Tackles AS VARCHAR(100)) + ')' AS Tackles,
		CAST(cgs.Tackled AS VARCHAR(100)) + ' (' + CAST(sc.Tackled AS VARCHAR(100)) + ')' AS Tackled,
		CAST(cgs.Fouls AS VARCHAR(100)) + ' (' + CAST(sc.Fouls AS VARCHAR(100)) + ')' AS Fouls,
		CAST(cgs.ClearancesBlocksInterceptions AS VARCHAR(100)) + ' (' + CAST(sc.ClearancesBlocksInterceptions AS VARCHAR(100)) + ')' AS ClearancesBlocksInterceptions,
		CAST(cgs.ErrorsLeadingToGoalAttempt AS VARCHAR(100)) + ' (' + CAST(sc.ErrorsLeadingToGoalAttempt AS VARCHAR(100)) + ')' AS ErrorsLeadingToGoalAttempt,
		CAST(cgs.ErrorsLeadingToGoal AS VARCHAR(100)) + ' (' + CAST(sc.ErrorsLeadingToGoal AS VARCHAR(100)) + ')' AS ErrorsLeadingToGoal,
		CAST(cgs.PenaltiesConceded AS VARCHAR(100)) + ' (' + CAST(sc.PenaltiesConceded AS VARCHAR(100)) + ')' AS PenaltiesConceded,
		CAST(cgs.OwnGoals AS VARCHAR(100)) + ' (' + CAST(sc.OwnGoals AS VARCHAR(100)) + ')' AS OwnGoals,
		CAST(cgs.Recoveries AS VARCHAR(100)) + ' (' + CAST(sc.Recoveries AS VARCHAR(100)) + ')' AS Recoveries,
		CAST(cgs.AttemptedPasses AS VARCHAR(100)) + ' (' + CAST(sc.AttemptedPasses AS VARCHAR(100)) + ')' AS AttemptedPasses,
		CAST(cgs.CompletedPasses AS VARCHAR(100)) + ' (' + CAST(sc.CompletedPasses AS VARCHAR(100)) + ')' AS CompletedPasses,
		CAST(cgs.KeyPasses AS VARCHAR(100)) + ' (' + CAST(sc.KeyPasses AS VARCHAR(100)) + ')' AS KeyPasses,
		CAST(cgs.BigChancesCreated AS VARCHAR(100)) + ' (' + CAST(sc.BigChancesCreated AS VARCHAR(100)) + ')' AS BigChancesCreated,
		CAST(cgs.OpenPlayCrosses AS VARCHAR(100)) + ' (' + CAST(sc.OpenPlayCrosses AS VARCHAR(100)) + ')' AS OpenPlayCrosses,
		CAST(cgs.Dribbles AS VARCHAR(100)) + ' (' + CAST(sc.Dribbles AS VARCHAR(100)) + ')' AS Dribbles,
		CAST(cgs.Assists AS VARCHAR(100)) + ' (' + CAST(sc.Assists AS VARCHAR(100)) + ')' AS Assists,
		CAST(cgs.GoalsScored AS VARCHAR(100)) + ' (' + CAST(sc.GoalsScored AS VARCHAR(100)) + ')' AS GoalsScored,
		CAST(cgs.TargetMissed AS VARCHAR(100)) + ' (' + CAST(sc.TargetMissed AS VARCHAR(100)) + ')' AS TargetMissed,
		CAST(cgs.PenaltiesMissed AS VARCHAR(100)) + ' (' + CAST(sc.PenaltiesMissed AS VARCHAR(100)) + ')' AS PenaltiesMissed,
		CAST(cgs.BigChancesMissed AS VARCHAR(100)) + ' (' + CAST(sc.BigChancesMissed AS VARCHAR(100)) + ')' AS BigChancesMissed,
		CAST(cgs.Offside AS VARCHAR(100)) + ' (' + CAST(sc.Offside AS VARCHAR(100)) + ')' AS Offside,
		cgs.PPG, 
		cgs.MinsPerPoint AS SelectionMinsPerPoint,
		sc.MinsPerPoint AS SeasonMinsPerPoint,
		pgc.PPG AS PrevPPG,
		cgs.PPG - pgc.PPG AS FormImprovementPPG,
		sc.PPG AS SeasonPPG,
		cgs.PPG - sc.PPG AS FormComparedToSeasonPPG
	FROM CurrentGameweekSelection cgs
	INNER JOIN PreviousGameweekComparison pgc
	ON cgs.PlayerKey = pgc.PlayerKey
	INNER JOIN SeasonComparison sc
	ON cgs.PlayerKey = sc.PlayerKey
	ORDER BY 
	CASE
		WHEN @OrderBy = 1 THEN SelectionPoints
		WHEN @OrderBy = 2 THEN sc.TotalPoints
		WHEN @OrderBy = 3 THEN cgs.PPG
		WHEN @OrderBy = 4 THEN sc.PPG
	END	
	DESC;
	--ORDER BY cgs.SelectionPoints DESC;

END