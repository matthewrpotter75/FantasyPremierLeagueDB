CREATE PROCEDURE dbo.GetBestSquadPlayerPointsForGameweekPeriod
(
	@SeasonKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MaxGoalkeepers INT = 2,
	@MaxDefendersAndMidfielders INT = 5,
	@MaxForwards INT = 3;

	IF OBJECT_ID('tempdb..#Best15Players') IS NOT NULL
		DROP TABLE #Best15Players;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	--Top 15 Players
	;WITH PlayerPointsSummed AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		GROUP BY ph.PlayerKey
	),
	PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pgs.Cost,
		pps.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM PlayerPointsSummed pps
		LEFT JOIN dbo.FactPlayerGameweekStatus pgs
		ON pps.PlayerKey = pgs.PlayerKey
		AND pgs.SeasonKey = @SeasonKey
		AND pgs.GameweekKey = @GameweekStart
		INNER JOIN dbo.DimPlayer p
		ON pps.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON pps.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
	),
	PlayersRankedExceptGKP AS
	(
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
	),
	Top2GKP AS
	(
		SELECT *
		FROM PlayersRanked
		WHERE PlayerPositionKey = 1
		AND PlayerPositionRank <= @MaxGoalkeepers
	),
	Top5DefendersAndMidfielders AS
	(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey IN (2,3)
		AND PlayerPositionRank <= @MaxDefendersAndMidfielders
	),
	Top3Strikers AS
	(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey = 4
		AND PlayerPositionRank <= @MaxForwards
	),
	Best15Players AS
	(
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, 12 AS PlayerRank
		FROM Top2GKP
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM Top5DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM Top3Strikers
	)
	SELECT 
	@SeasonKey AS SeasonKey,
	@GameweekStart AS GameweekStart,
	@GameweekEnd AS GameweekEnd,
	PlayerKey, 
	PlayerPositionKey,
	PlayerPositionShort,
	Cost,
	TotalPoints,
	(TotalPoints * 1.00)/Cost AS PointsPerCost,
	1 AS IsPlay
	INTO #Best15Players
	FROM Best15Players;

	SELECT p.PlayerName, bp.*
	FROM #Best15Players bp
	INNER JOIN dbo.DimPlayer p
	ON bp.PlayerKey = p.PlayerKey
	ORDER BY PlayerPositionKey, TotalPoints DESC;

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #Best15Players;

	SELECT p.PlayerName, bp.*,
	ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PointsRank
	FROM #Best15Players bp
	INNER JOIN dbo.DimPlayer p
	ON bp.PlayerKey = p.PlayerKey
	ORDER BY TotalPoints DESC;

	SELECT p.PlayerName, bp.*,
	ROW_NUMBER() OVER (ORDER BY PointsPerCost DESC) AS PointsPerCostRank
	FROM #Best15Players bp
	INNER JOIN dbo.DimPlayer p
	ON bp.PlayerKey = p.PlayerKey
	ORDER BY PointsPerCost DESC;

	--Combined Rank
	;WITH PointsRank AS
	(
		SELECT p.PlayerName, bp.*,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PointsRank
		FROM #Best15Players bp
		INNER JOIN dbo.DimPlayer p
		ON bp.PlayerKey = p.PlayerKey
	),
	PointsPerCostRank AS
	(
		SELECT p.PlayerName, bp.*,
		ROW_NUMBER() OVER (ORDER BY PointsPerCost DESC) AS PointsPerCostRank
		FROM #Best15Players bp
		INNER JOIN dbo.DimPlayer p
		ON bp.PlayerKey = p.PlayerKey
	)
	SELECT pr.*, ppcr.PointsPerCostRank, pr.PointsRank + ppcr.PointsPerCostRank AS CombinedRank
	FROM PointsRank pr
	INNER JOIN PointsPerCostRank ppcr
	ON pr.PlayerKey = ppcr.PlayerKey
	ORDER BY CombinedRank DESC;

	--need to get the most cost loss for the least points loss

	;WITH PlayerPointsSummed AS
	(
		SELECT ph.PlayerKey,
		pa.PlayerPositionKey,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	),
	PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pgs.Cost,
		pps.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM PlayerPointsSummed pps
		LEFT JOIN dbo.FactPlayerGameweekStatus pgs
		ON pps.PlayerKey = pgs.PlayerKey
		AND pgs.SeasonKey = @SeasonKey
		AND pgs.GameweekKey = @GameweekStart
		INNER JOIN dbo.DimPlayer p
		ON pps.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON pps.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
	),
	PointAndCostRangeForEachPosition AS
	(
		SELECT PlayerPositionKey, 
		MIN(TotalPoints) AS MinTotalPoints,
		MAX(TotalPoints) AS MaxTotalPoints,
		MIN(Cost) AS MinTotalCost,
		MAX(Cost) AS MaxTotalCost
		FROM PlayersRanked
		WHERE PlayerPositionRank <= 10
		GROUP BY PlayerPositionKey
	)
	SELECT *
	FROM PointAndCostRangeForEachPosition;

	;WITH PlayerPointsSummed AS
	(
		SELECT ph.PlayerKey,
		pa.PlayerPositionKey,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	),
	PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pgs.Cost,
		pps.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM PlayerPointsSummed pps
		LEFT JOIN dbo.FactPlayerGameweekStatus pgs
		ON pps.PlayerKey = pgs.PlayerKey
		AND pgs.SeasonKey = @SeasonKey
		AND pgs.GameweekKey = @GameweekStart
		INNER JOIN dbo.DimPlayer p
		ON pps.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON pps.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
	)
	SELECT *,
	(TotalPoints * 1.0)/Cost AS PointsPerCost
	FROM PlayersRanked
	WHERE PlayerPositionRank <= 15
	--ORDER BY PlayerPositionKey, TotalPoints DESC;
	ORDER BY PlayerPositionKey, PointsPerCost DESC;

	--MERGE INTO dbo.BestTeamSquad AS Target 
	--USING 
	--(
	--	SELECT 
	--	@SeasonKey AS SeasonKey,
	--	@GameweekStart AS GameweekStart,
	--	@GameweekEnd AS GameweekEnd,
	--	PlayerKey, 
	--	PlayerPositionKey,
	--	Cost,
	--	TotalPoints,
	--	1 AS IsPlay
	--	FROM #Best15Players
	--)
	--AS Source (SeasonKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	--ON Source.SeasonKey = Target.SeasonKey
	--AND Source.GameweekStart = Target.GameweekStart
	--AND Source.GameweekEnd = Target.GameweekEnd
	--AND Source.PlayerKey = Target.PlayerKey
	--AND Source.PlayerPositionKey = Target.PlayerPositionKey
	--WHEN NOT MATCHED BY TARGET THEN
	--INSERT (SeasonKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	--VALUES (Source.SeasonKey, Source.GameweekStart, Source.GameweekEnd, Source.PlayerKey, Source.PlayerPositionKey, Source.Cost, Source.TotalPoints, Source.IsPlay);

	--UPDATE bts
	--SET IsCaptain = 1
	--FROM dbo.BestTeamSquad bts
	--INNER JOIN
	--(
	--	SELECT PlayerKey,
	--	ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
	--	FROM dbo.BestTeamSquad
	--	WHERE SeasonKey = @SeasonKey
	--	AND GameweekStart = @GameweekStart
	--	AND GameweekEnd = @GameweekEnd
	--) cpt
	--ON cpt.PlayerKey = bts.PlayerKey
	--AND cpt.PlayerRank = 1

	IF @Debug = 1
	BEGIN

		SELECT 'PlayersRankedExceptGKP';
		
		--PlayersRanked
		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekStart
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		)
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
		ORDER BY PlayerPositionKey, PlayerPositionRank;

		SELECT 'Top 2 GKP';

		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekStart
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		)
		--Top2GKP AS
		--(
		SELECT *
		FROM PlayersRanked
		WHERE PlayerPositionKey = 1
		AND PlayerPositionRank <= @MaxGoalkeepers;

		SELECT 'Top 5 Defenders And Midfielders';

		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekStart
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		),
		Top2GKP AS
		(
			SELECT *
			FROM PlayersRanked
			WHERE PlayerPositionKey = 1
			AND PlayerPositionRank <= @MaxGoalkeepers
		)
		--Top5DefendersAndMidfielders AS
		--(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey IN (2,3)
		AND PlayerPositionRank <= @MaxDefendersAndMidfielders;

		SELECT 'Top 3 Strikers';

		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekStart
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		),
		Top2GKP AS
		(
			SELECT *
			FROM PlayersRanked
			WHERE PlayerPositionKey = 1
			AND PlayerPositionRank <= @MaxGoalkeepers
		),
		Top5DefendersAndMidfielders AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey IN (2,3)
			AND PlayerPositionRank <= @MaxDefendersAndMidfielders
		)
		--Top3Strikers AS
		--(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey = 4
		AND PlayerPositionRank <= @MaxForwards;

		SELECT 'Top 15 players';

		--Top 15 Players
		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekStart
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		),
		Top2GKP AS
		(
			SELECT *
			FROM PlayersRanked
			WHERE PlayerPositionKey = 1
			AND PlayerPositionRank <= @MaxGoalkeepers
		),
		Top5DefendersAndMidfielders AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey IN (2,3)
			AND PlayerPositionRank <= @MaxDefendersAndMidfielders
		),
		Top3Strikers AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey = 4
			AND PlayerPositionRank <= @MaxForwards
		)
		--Best15Players AS
		--(
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, 12 AS PlayerRank, 1 AS CodePath
		FROM Top2GKP
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank, 2 AS CodePath
		FROM Top5DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank, 3 AS CodePath
		FROM Top3Strikers
		ORDER BY CodePath, PlayerPositionKey, TotalPoints DESC;
	
	END

END