CREATE PROCEDURE dbo.GetPlayerPointsBetweenGameweeksForSeason
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
			CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS PreviousPPG,
			CAST((SUM(ph.TotalPoints) * 1.00)/(pcs.Cost * 1.0/10) AS DECIMAL(5,2)) AS PreviousPPC,
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
		GROUP BY p.PlayerKey, pcs.Cost

	),
	SeasonComparison AS
	(
		SELECT p.PlayerKey,
			COUNT(1) AS TotalGames,
			SUM(CASE
				WHEN ph.[Minutes] > 0 THEN 1
				ELSE 0
			END) AS GamesPlayedIn,
			SUM(CASE
				WHEN ph.[Minutes] >= 45 THEN 1
				ELSE 0
			END) AS MeaningfulGames,
			SUM(CASE
				WHEN ph.[Minutes] >= 45 THEN ph.TotalPoints
				ELSE 0
			END) AS MeaningfulPoints,
			SUM(ph.[Minutes]) AS TotalMinutes,
			SUM(ph.TotalPoints) AS TotalPoints,
			CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS SeasonPPG,
			CAST(((SUM(ph.TotalPoints) * 1.00)/(pcs.Cost * 1.0/10)) * (38.0/COUNT(1)) AS DECIMAL(5,2)) AS SeasonPPC,
			CASE 
				WHEN SUM(ph.TotalPoints) <> 0
				THEN CAST(SUM(ph.[Minutes] * 1.00)/SUM(ph.TotalPoints) AS DECIMAL(5,2))
				ELSE 0
			END AS SeasonMinsPerPoint
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
		GROUP BY p.PlayerKey, pcs.Cost
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
			CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS SelectionPPG,
			CAST((SUM(ph.TotalPoints) * 1.00)/(pcs.Cost * 1.0/10) AS DECIMAL(5,2)) AS SelectionPPC,
			CASE WHEN SUM(ph.TotalPoints) <> 0
				THEN CAST(SUM(ph.[Minutes] * 1.00)/SUM(ph.TotalPoints) AS DECIMAL(5,2))
				ELSE 0
			END AS SelectionMinsPerPoint,
			MIN(td.Difficulty) AS MinDifficulty, 
			MAX(td.Difficulty) AS MaxDifficulty, 
			CAST((SUM(td.Difficulty) * 1.00)/COUNT(1) AS DECIMAL(5,2)) AS AveDifficulty
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
		INNER JOIN dbo.DimTeamDifficulty td
		ON ot.TeamKey = td.TeamKey
		AND ph.WasHome = td.IsTeamHome
		AND td.SeasonKey = @SeasonKey
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
	SELECT cgs.PlayerKey, 
		cgs.PlayerName, 
		cgs.PlayerPosition, 
		cgs.TeamName, 
		cgs.Cost,
		sc.TotalGames,
		sc.GamesPlayedIn,
		sc.MeaningfulGames,
		sc.TotalMinutes,
		sc.TotalPoints,
		sc.MeaningfulPoints,
		sc.SeasonPPG,
		CASE
			WHEN sc.GamesPlayedIn > 0 THEN CAST(((sc.TotalPoints) * 1.00)/sc.GamesPlayedIn AS DECIMAL(5,2)) 
			ELSE 0
		END AS RealSeasonPPG,
		CASE
			WHEN sc.MeaningfulGames > 0 THEN CAST(((sc.MeaningfulPoints) * 1.00)/sc.MeaningfulGames AS DECIMAL(5,2)) 
			ELSE 0
		END AS MeaningfulSeasonPPG,
		sc.SeasonPPC,
		cgs.SelectionGames, 
		cgs.SelectionMinutes, 
		cgs.SelectionPoints, 
		cgs.SelectionPPG,
		cgs.SelectionPPC,
		CASE 
			WHEN cgs.SelectionPPC <> 0 THEN cgs.SelectionPPG/cgs.SelectionPPC 
			ELSE 0
		END
		AS SelectionPPGPerCostIndex,
		CASE 
			WHEN sc.SeasonPPC <> 0 THEN sc.SeasonPPG/sc.SeasonPPC 
			ELSE 0
		END
		AS SeasonPPGPerCostIndex,
		cgs.SelectionMinsPerPoint,
		cgs.MinDifficulty, 
		cgs.MaxDifficulty, 
		cgs.AveDifficulty,
		pgc.PreviousPPG,
		cgs.SelectionPPG - pgc.PreviousPPG AS FormImprovementPPG,
		cgs.SelectionPPC - pgc.PreviousPPC AS FormImprovementPPC,		
		cgs.SelectionPPG - sc.SeasonPPG AS FormComparedToSeasonPPG,
		cgs.SelectionPPC - sc.SeasonPPC AS FormComparedToSeasonPPC
	FROM CurrentGameweekSelection cgs
	INNER JOIN PreviousGameweekComparison pgc
	ON cgs.PlayerKey = pgc.PlayerKey
	INNER JOIN SeasonComparison sc
	ON cgs.PlayerKey = sc.PlayerKey
	ORDER BY 
	CASE
		WHEN @OrderBy = 1 THEN SelectionPoints
		WHEN @OrderBy = 2 THEN sc.TotalPoints
		WHEN @OrderBy = 3 THEN cgs.SelectionPPG
		WHEN @OrderBy = 4 THEN sc.SeasonPPG
		WHEN @OrderBy = 5 THEN cgs.SelectionPPG - pgc.PreviousPPG
		WHEN @OrderBy = 6 THEN cgs.SelectionPPG - sc.SeasonPPG
		WHEN @OrderBy = 7 THEN cgs.SelectionPPC
		WHEN @OrderBy = 8 THEN cgs.SelectionPPC - sc.SeasonPPC
	END	
	DESC;
	--ORDER BY cgs.SelectionPoints DESC;

END