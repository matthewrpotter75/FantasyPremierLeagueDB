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

	DECLARE @TotalCost INT,
	@Overspend INT,
	@PlayerKeyToChange INT,
	@PlayerToChangeCost INT,
	@PlayerToChangePlayerPositionKey INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@MinCostToSave INT,
	@PlayerPositionKey INT,
	@Loop INT,
	@Cnt INT;

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
	ROW_NUMBER() OVER (ORDER BY Cost DESC, PlayerKey) AS CostRank,
	PlayerPositionRank,
	1 AS IsPlay
	INTO #Best15Players
	FROM Best15Players;

	SELECT p.PlayerName, bp.*
	FROM #Best15Players bp
	INNER JOIN dbo.DimPlayer p
	ON bp.PlayerKey = p.PlayerKey
	ORDER BY PlayerPositionKey, TotalPoints DESC;

	SELECT 'Before';

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #Best15Players;

	--need to get the most cost loss for the least points loss
	--need to identify a player to change, change without losing too many points, and loop round until total cost is under £100m

	;WITH PlayerTotalPoints AS
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
	MaxPlayerPoints AS
	(
		SELECT PlayerPositionKey,
		MAX(TotalPoints) AS MaxPlayerPoints
		FROM PlayerTotalPoints
		GROUP BY PlayerPositionKey
	),
	PlayerCounts AS
	(
		SELECT ptp.PlayerPositionKey,
		COUNT(PlayerKey) AS Players
		FROM PlayerTotalPoints ptp
		INNER JOIN MaxPlayerPoints mpp
		ON ptp.PlayerPositionKey = mpp.PlayerPositionKey
		WHERE ptp.TotalPoints >= mpp.MaxPlayerPoints - 10
		GROUP BY ptp.PlayerPositionKey
	)
	SELECT *,
	ROW_NUMBER() OVER (ORDER BY Players DESC) AS PlayersRank
	INTO #PlayerCounts
	FROM PlayerCounts
	ORDER BY PlayersRank;

	IF @Debug=1
		SELECT * FROM #PlayerCounts;

	--Get how much needed to save to get within budget
	SELECT @TotalCost = SUM(Cost)
	FROM #Best15Players;

	IF @Debug=1
		SELECT @TotalCost AS TotalCost;

	SELECT @Overspend = @TotalCost - 1000;
	SELECT @Overspend AS Overspend;

	SELECT @Loop = 1;
	SELECT @Cnt = 1;
	SELECT @PlayerPositionKey = 4;

	WHILE @Overspend > 0
	BEGIN	

		IF @Debug=1
			SELECT @Loop AS [Loop];

		IF @Overspend > 90
		BEGIN
			SET @MinCostToSave = 30;
		END
		ELSE
		BEGIN
			IF @Overspend > 50
			BEGIN
				SET @MinCostToSave = 20;
			END
			ELSE 
			BEGIN
				SET @MinCostToSave = 5;
			END
		END

		--Get Player to change
		IF @Loop < 5
		BEGIN

			SELECT TOP 1 @PlayerKeyToChange = PlayerKey 
			FROM #Best15Players
			WHERE PlayerPositionKey = @PlayerPositionKey
			ORDER BY Cost DESC, TotalPoints;

		END
		ELSE
		BEGIN

			SELECT TOP 1 @PlayerKeyToChange = PlayerKey
			FROM #Best15Players
			WHERE PlayerPositionKey IN
			(
				SELECT PlayerPositionKey
				FROM #PlayerCounts
				WHERE PlayersRank = @Cnt
			)
			ORDER BY Cost DESC, TotalPoints;

		END

		SELECT @PlayerToChangePlayerPositionKey = PlayerPositionKey FROM dbo.DimPlayerAttribute WHERE PlayerKey = @PlayerKeyToChange AND SeasonKey = @SeasonKey;

		SELECT @PlayerToChangeCost = Cost FROM #Best15Players WHERE PlayerKey = @PlayerKeyToChange;

		IF @Debug=1
			SELECT @PlayerKeyToChange AS PlayerKeyToChange, @PlayerToChangeCost AS PlayerToChangeCost;

		--Get player to move into the squad
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
			WHERE pa.PlayerPositionKey = @PlayerToChangePlayerPositionKey
		),
		NewPotentialPlayerRankedByTotalPoints AS
		(
			SELECT PlayerKey, 
			Cost,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS TotalPointsRank
			FROM PlayersRanked pr
			WHERE PlayerPositionKey = @PlayerToChangePlayerPositionKey
			AND Cost <= @PlayerToChangeCost - @MinCostToSave
			AND NOT EXISTS
			(
				SELECT 1
				FROM #Best15Players
				WHERE PlayerKey = pr.PlayerKey
			)
		)
		SELECT @PlayerKeyToAdd = PlayerKey, @PlayerToAddCost = Cost
		FROM NewPotentialPlayerRankedByTotalPoints
		WHERE TotalPointsRank = 1;

		IF @Debug=1
			SELECT @PlayerKeyToAdd AS PlayerKeyToAdd, @PlayerToAddCost AS PlayerToAddCost;

		--Update Old player with new player in temp table
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
		newplayer AS
		(
			SELECT @PlayerKeyToChange AS PlayerKeyToChange,
			@SeasonKey AS SeasonKey,
			@GameweekStart AS GameweekStart,
			@GameweekEnd AS GameweekEnd,
			PlayerKey, 
			PlayerPositionKey,
			PlayerPositionShort,
			Cost,
			TotalPoints,
			(TotalPoints * 1.00)/Cost AS PointsPerCost,
			ROW_NUMBER() OVER (ORDER BY Cost DESC, PlayerKey) AS CostRank,
			PlayerPositionRank,
			1 AS IsPlay
			FROM PlayersRanked
			WHERE PlayerKey = @PlayerKeyToAdd
		)
		UPDATE bp
		SET PlayerKey = @PlayerKeyToAdd,
		Cost = newplayer.Cost,
		TotalPoints = newplayer.TotalPoints,
		PointsPerCost = newplayer.PointsPerCost
		FROM #Best15Players bp
		INNER JOIN newplayer
		ON bp.PlayerKey = newplayer.PlayerKeyToChange
		WHERE bp.PlayerKey = @PlayerKeyToChange;		

		SELECT @Overspend = @Overspend - (@PlayerToChangeCost - @PlayerToAddCost);
		SELECT @Overspend AS Overspend;

		SELECT @Loop = @Loop + 1;
		SELECT @Cnt = @Cnt + 1;
		SELECT @PlayerPositionKey = @PlayerPositionKey - 1;

		IF @PlayerPositionKey = 0
		BEGIN
			SET @PlayerPositionKey = 4;
			SET @Cnt = 1;
		END

		IF @Cnt > 10
			SET @Overspend = 0;

	END

	SELECT p.PlayerName, bp.*
	FROM #Best15Players bp
	INNER JOIN dbo.DimPlayer p
	ON bp.PlayerKey = p.PlayerKey
	ORDER BY PlayerPositionKey, TotalPoints DESC;

	MERGE INTO dbo.BestTeamSquad AS Target 
	USING 
	(
		SELECT 
		@SeasonKey AS SeasonKey,
		@GameweekStart AS GameweekStart,
		@GameweekEnd AS GameweekEnd,
		PlayerKey, 
		PlayerPositionKey,
		Cost,
		TotalPoints,
		1 AS IsPlay
		FROM #Best15Players
	)
	AS Source (SeasonKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	ON Source.SeasonKey = Target.SeasonKey
	AND Source.GameweekStart = Target.GameweekStart
	AND Source.GameweekEnd = Target.GameweekEnd
	AND Source.PlayerKey = Target.PlayerKey
	AND Source.PlayerPositionKey = Target.PlayerPositionKey
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (SeasonKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	VALUES (Source.SeasonKey, Source.GameweekStart, Source.GameweekEnd, Source.PlayerKey, Source.PlayerPositionKey, Source.Cost, Source.TotalPoints, Source.IsPlay)
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

	UPDATE bts
	SET IsCaptain = 1
	FROM dbo.BestTeamSquad bts
	INNER JOIN
	(
		SELECT PlayerKey,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM dbo.BestTeamSquad
		WHERE SeasonKey = @SeasonKey
		AND GameweekStart = @GameweekStart
		AND GameweekEnd = @GameweekEnd
	) cpt
	ON cpt.PlayerKey = bts.PlayerKey
	AND cpt.PlayerRank = 1

	SELECT 'After';

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #Best15Players;	

	--PointsRank
	--SELECT p.PlayerName, bp.*,
	--ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PointsRank
	--FROM #Best15Players bp
	--INNER JOIN dbo.DimPlayer p
	--ON bp.PlayerKey = p.PlayerKey
	--ORDER BY TotalPoints DESC;

	--PointsPerCostRank
	--SELECT p.PlayerName, bp.*,
	--ROW_NUMBER() OVER (ORDER BY PointsPerCost DESC) AS PointsPerCostRank
	--FROM #Best15Players bp
	--INNER JOIN dbo.DimPlayer p
	--ON bp.PlayerKey = p.PlayerKey
	--ORDER BY PointsPerCost DESC;

	--Combined Rank
	--;WITH PointsRank AS
	--(
	--	SELECT p.PlayerName, bp.*,
	--	ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PointsRank
	--	FROM #Best15Players bp
	--	INNER JOIN dbo.DimPlayer p
	--	ON bp.PlayerKey = p.PlayerKey
	--),
	--PointsPerCostRank AS
	--(
	--	SELECT p.PlayerName, bp.*,
	--	ROW_NUMBER() OVER (ORDER BY PointsPerCost DESC) AS PointsPerCostRank
	--	FROM #Best15Players bp
	--	INNER JOIN dbo.DimPlayer p
	--	ON bp.PlayerKey = p.PlayerKey
	--)
	--SELECT pr.*, ppcr.PointsPerCostRank, pr.PointsRank + ppcr.PointsPerCostRank AS CombinedRank
	--FROM PointsRank pr
	--INNER JOIN PointsPerCostRank ppcr
	--ON pr.PlayerKey = ppcr.PlayerKey
	--ORDER BY CombinedRank DESC;

	--PointAndCostRangeForEachPosition
	--;WITH PlayerPointsSummed AS
	--(
	--	SELECT ph.PlayerKey,
	--	pa.PlayerPositionKey,
	--	SUM(ph.TotalPoints) AS TotalPoints
	--	FROM dbo.FactPlayerHistory ph
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON ph.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	WHERE ph.SeasonKey = @SeasonKey
	--	AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	--	GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	--),
	--PlayersRanked AS
	--(
	--	SELECT p.PlayerKey,
	--	p.PlayerName, 
	--	pa.PlayerPositionKey,
	--	pp.PlayerPositionShort,
	--	pgs.Cost,
	--	pps.TotalPoints,
	--	ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
	--	--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
	--	FROM PlayerPointsSummed pps
	--	LEFT JOIN dbo.FactPlayerGameweekStatus pgs
	--	ON pps.PlayerKey = pgs.PlayerKey
	--	AND pgs.SeasonKey = @SeasonKey
	--	AND pgs.GameweekKey = @GameweekStart
	--	INNER JOIN dbo.DimPlayer p
	--	ON pps.PlayerKey = p.PlayerKey
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON pps.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	INNER JOIN dbo.DimPlayerPosition pp
	--	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	--),
	--PointAndCostRangeForEachPosition AS
	--(
	--	SELECT PlayerPositionKey, 
	--	MIN(TotalPoints) AS MinTotalPoints,
	--	MAX(TotalPoints) AS MaxTotalPoints,
	--	MIN(Cost) AS MinTotalCost,
	--	MAX(Cost) AS MaxTotalCost
	--	FROM PlayersRanked
	--	WHERE PlayerPositionRank <= 10
	--	GROUP BY PlayerPositionKey
	--)
	--SELECT *
	--FROM PointAndCostRangeForEachPosition;

	--;WITH PlayerPointsSummed AS
	--(
	--	SELECT ph.PlayerKey,
	--	pa.PlayerPositionKey,
	--	SUM(ph.TotalPoints) AS TotalPoints
	--	FROM dbo.FactPlayerHistory ph
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON ph.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	WHERE ph.SeasonKey = @SeasonKey
	--	AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	--	GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	--),
	--PlayersRanked AS
	--(
	--	SELECT p.PlayerKey,
	--	p.PlayerName, 
	--	pa.PlayerPositionKey,
	--	pp.PlayerPositionShort,
	--	pgs.Cost,
	--	pps.TotalPoints,
	--	ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
	--	--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
	--	FROM PlayerPointsSummed pps
	--	LEFT JOIN dbo.FactPlayerGameweekStatus pgs
	--	ON pps.PlayerKey = pgs.PlayerKey
	--	AND pgs.SeasonKey = @SeasonKey
	--	AND pgs.GameweekKey = @GameweekStart
	--	INNER JOIN dbo.DimPlayer p
	--	ON pps.PlayerKey = p.PlayerKey
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON pps.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	INNER JOIN dbo.DimPlayerPosition pp
	--	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	--)
	--SELECT *,
	--(TotalPoints * 1.0)/Cost AS PointsPerCost
	--FROM PlayersRanked
	--WHERE PlayerPositionRank <= 15
	----ORDER BY PlayerPositionKey, TotalPoints DESC;
	--ORDER BY PlayerPositionKey, PointsPerCost DESC;

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