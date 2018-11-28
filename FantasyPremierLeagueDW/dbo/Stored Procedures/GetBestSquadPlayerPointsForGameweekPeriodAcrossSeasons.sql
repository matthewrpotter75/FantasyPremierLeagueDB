CREATE PROCEDURE dbo.GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasons
(
	@SeasonStartKey INT = NULL,
	@SeasonEndKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE 
	@TotalCost INT,
	@Overspend INT,
	@PlayerKeyToChange INT,
	@PlayerToChangeCost INT,
	@PlayerToChangePoints INT,
	@PlayerToChangePlayerPositionKey INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@PlayerToAddPoints INT,
	@PlayerToAddPlayerPositionKey INT,
	@MinCostToSave INT,
	@PlayerPositionKey INT,
	@Loop INT,
	@Cnt INT,
	@PlayerToAddCount INT;

	DECLARE @MaxGoalkeepers INT = 2,
	@MaxDefendersAndMidfielders INT = 5,
	@MaxForwards INT = 3;

	IF OBJECT_ID('tempdb..#Best15Players') IS NOT NULL
		DROP TABLE #Best15Players;

	IF @SeasonStartKey IS NULL
	BEGIN
		SELECT @SeasonStartKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @SeasonEndKey IS NULL
		SELECT @SeasonEndKey = @SeasonStartKey;

	--Top 15 Players
	;WITH PlayerPointsSummed AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
		OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
		GROUP BY ph.PlayerKey
	),
	PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pcs.Cost,
		pps.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM PlayerPointsSummed pps
		LEFT JOIN dbo.FactPlayerCurrentStats pcs
		ON pps.PlayerKey = pcs.PlayerKey
		INNER JOIN dbo.DimPlayer p
		ON pps.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON pps.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonEndKey
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
	@SeasonStartKey AS SeasonStartKey,
	@SeasonEndKey AS SeasonEndKey,
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
	ORDER BY bp.PlayerPositionKey, bp.PlayerKey;
	--ORDER BY PlayerPositionKey, TotalPoints DESC;

	SELECT 'Before';

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #Best15Players;

	--need to get the most cost loss for the least points loss
	--need to identify a player to change, change without losing too many points, and loop round until total cost is under �100m

	;WITH PlayerTotalPoints AS
	(
		SELECT ph.PlayerKey,
		pa.PlayerPositionKey,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonEndKey
		WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
		OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
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
	BEGIN
		
		SELECT 'PlayerCounts';
		SELECT * FROM #PlayerCounts;

	END

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

			SELECT TOP 1 @PlayerKeyToChange = PlayerKey,
			@PlayerToChangePlayerPositionKey = PlayerPositionKey,
			@PlayerToChangeCost = Cost,
			@PlayerToChangePoints = TotalPoints
			FROM #Best15Players
			WHERE PlayerPositionKey = @PlayerPositionKey
			ORDER BY Cost DESC, TotalPoints;

		END
		ELSE
		BEGIN

			SELECT TOP 1 @PlayerKeyToChange = PlayerKey,
			@PlayerToChangePlayerPositionKey = PlayerPositionKey,
			@PlayerToChangeCost = Cost,
			@PlayerToChangePoints = TotalPoints
			FROM #Best15Players
			WHERE PlayerPositionKey IN
			(
				SELECT PlayerPositionKey
				FROM #PlayerCounts
				WHERE PlayersRank = @Cnt
			)
			ORDER BY Cost DESC, TotalPoints;

		END

		--SELECT @PlayerToChangePlayerPositionKey = PlayerPositionKey FROM dbo.DimPlayerAttribute WHERE PlayerKey = @PlayerKeyToChange AND SeasonKey = @SeasonEndKey;

		--SELECT @PlayerToChangeCost = Cost FROM #Best15Players WHERE PlayerKey = @PlayerKeyToChange;

		IF @Debug=1
			SELECT @PlayerKeyToChange AS PlayerKeyToChange, @PlayerToChangePlayerPositionKey AS PlayerToChangePlayerPositionKey, @PlayerToChangeCost AS PlayerToChangeCost, @PlayerToChangePoints AS PlayerToChangePoints;

		SELECT @PlayerToAddCount = 0;
		
		WHILE @PlayerToAddCount = 0
		BEGIN

			--Get player to move into the squad
			;WITH PlayerPointsSummed AS
			(
				SELECT ph.PlayerKey,
				SUM(ph.TotalPoints) AS TotalPoints
				FROM dbo.FactPlayerHistory ph
				INNER JOIN dbo.DimPlayerAttribute pa
				ON ph.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonEndKey
				WHERE pa.PlayerPositionKey = @PlayerToChangePlayerPositionKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM #Best15Players bp
					WHERE bp.PlayerKey = ph.PlayerKey
				)
				AND
				(
					(ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
					OR 
					(ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
				)
				GROUP BY ph.PlayerKey
			),
			PlayersRanked AS
			(
				SELECT p.PlayerKey,
				p.PlayerName, 
				pa.PlayerPositionKey,
				--pp.PlayerPositionShort,
				pcs.Cost,
				pcs.TotalPoints,
				ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
				--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
				FROM PlayerPointsSummed pps
				LEFT JOIN dbo.FactPlayerCurrentStats pcs
				ON pps.PlayerKey = pcs.PlayerKey
				INNER JOIN dbo.DimPlayer p
				ON pps.PlayerKey = p.PlayerKey
				INNER JOIN dbo.DimPlayerAttribute pa
				ON pps.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonEndKey
				--INNER JOIN dbo.DimPlayerPosition pp
				--ON pa.PlayerPositionKey = pp.PlayerPositionKey
				WHERE pa.PlayerPositionKey = @PlayerToChangePlayerPositionKey
			),
			NewPotentialPlayerRankedByTotalPoints AS
			(
				SELECT PlayerKey, 
				Cost,
				TotalPoints,
				PlayerPositionKey,
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
			SELECT TOP (1) @PlayerKeyToAdd = PlayerKey, @PlayerToAddPlayerPositionKey = PlayerPositionKey, @PlayerToAddCost = Cost, @PlayerToAddPoints = TotalPoints
			FROM NewPotentialPlayerRankedByTotalPoints nppr
			WHERE PlayerPositionKey = @PlayerToChangePlayerPositionKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM #Best15Players
				WHERE PlayerKey = nppr.PlayerKey
			)
			ORDER BY TotalPointsRank;

			SET @PlayerToAddCount = @@ROWCOUNT;

			IF @PlayerToAddCount = 0
				SET @MinCostToSave = @MinCostToSave - 1;

		END

		IF @Debug=1
			SELECT @PlayerKeyToAdd AS PlayerKeyToAdd, @PlayerToAddPlayerPositionKey AS PlayerToAddPlayerPositionKey, @PlayerToAddCost AS PlayerToAddCost, @PlayerToAddPoints AS PlayerToAddPoints;

		--Update Old player with new player in temp table
		UPDATE #Best15Players
		SET PlayerKey = @PlayerKeyToAdd,
		PlayerPositionKey = @PlayerToAddPlayerPositionKey,
		Cost = @PlayerToAddCost,
		TotalPoints = @PlayerToAddPoints,
		PointsPerCost = (TotalPoints * 1.00)/Cost
		WHERE SeasonStartKey = @SeasonStartKey
		AND SeasonEndKey = @SeasonEndKey
		AND GameweekStart = @GameweekStart
		AND GameweekEnd = @GameweekEnd
		AND PlayerKey = @PlayerKeyToChange;		

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

		IF @Loop > 20
			SET @Overspend = 0;

		IF @Debug = 1
			SELECT dp.PlayerName, bp.*
			FROM #Best15Players bp
			INNER JOIN dbo.DimPlayer dp
			ON bp.PlayerKey = dp.PlayerKey
			ORDER BY bp.PlayerPositionKey, bp.PlayerKey;

	END

	--SELECT p.PlayerName, bp.*
	--FROM #Best15Players bp
	--INNER JOIN dbo.DimPlayer p
	--ON bp.PlayerKey = p.PlayerKey
	--ORDER BY PlayerPositionKey, TotalPoints DESC;

	IF @Debug = 1
	BEGIN

		SELECT 'Merge source';

		SELECT 
		@SeasonStartKey AS SeasonStartKey,
		@SeasonEndKey AS SeasonEndKey,
		@GameweekStart AS GameweekStart,
		@GameweekEnd AS GameweekEnd,
		PlayerKey, 
		PlayerPositionKey,
		Cost,
		TotalPoints,
		1 AS IsPlay
		FROM #Best15Players

	END
	
	MERGE INTO dbo.BestTeamSquad AS Target 
	USING 
	(
		SELECT 
		@SeasonStartKey AS SeasonStartKey,
		@SeasonEndKey AS SeasonEndKey,
		@GameweekStart AS GameweekStart,
		@GameweekEnd AS GameweekEnd,
		PlayerKey, 
		PlayerPositionKey,
		Cost,
		TotalPoints,
		1 AS IsPlay
		FROM #Best15Players
	)
	AS Source (SeasonStartKey, SeasonEndKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	ON Source.SeasonStartKey = Target.SeasonStartKey
	AND Source.SeasonEndKey = Target.SeasonEndKey
	AND Source.GameweekStart = Target.GameweekStart
	AND Source.GameweekEnd = Target.GameweekEnd
	AND Source.PlayerKey = Target.PlayerKey
	AND Source.PlayerPositionKey = Target.PlayerPositionKey
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (SeasonStartKey, SeasonEndKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	VALUES (Source.SeasonStartKey, Source.SeasonEndKey, Source.GameweekStart, Source.GameweekEnd, Source.PlayerKey, Source.PlayerPositionKey, Source.Cost, Source.TotalPoints, Source.IsPlay)
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

	UPDATE bts
	SET IsCaptain = 0
	FROM dbo.BestTeamSquad bts
	WHERE SeasonStartKey = @SeasonStartKey
	AND SeasonEndKey = @SeasonEndKey
	AND GameweekStart = @GameweekStart
	AND GameweekEnd = @GameweekEnd;

	UPDATE bts
	SET IsCaptain = 1
	FROM dbo.BestTeamSquad bts
	INNER JOIN
	(
		SELECT PlayerKey,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM dbo.BestTeamSquad
		WHERE SeasonStartKey = @SeasonStartKey
		AND SeasonEndKey = @SeasonEndKey
		AND GameweekStart = @GameweekStart
		AND GameweekEnd = @GameweekEnd
	) cpt
	ON cpt.PlayerKey = bts.PlayerKey
	AND cpt.PlayerRank = 1

	SELECT 'After';

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #Best15Players;

	SELECT bts.*, p.PlayerName
	FROM dbo.BestTeamSquad bts
	INNER JOIN DimPlayer p
	ON bts.PlayerKey = p.PlayerKey
	WHERE SeasonStartKey = @SeasonStartKey
	AND SeasonEndKey = @SeasonEndKey
	AND GameweekStart = @GameweekStart
	AND GameweekEnd = @GameweekEnd;

	IF @Debug = 1
	BEGIN

		SELECT 'PlayersRankedExceptGKP';
		
		--PlayersRanked
		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
			OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
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
			AND pgs.SeasonKey = @SeasonEndKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonEndKey
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
			WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
			OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
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
			AND pgs.SeasonKey = @SeasonEndKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonEndKey
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
			WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
			OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
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
			AND pgs.SeasonKey = @SeasonEndKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonEndKey
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
			WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
			OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
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
			AND pgs.SeasonKey = @SeasonEndKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonEndKey
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
			WHERE (ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
			OR (ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
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
			AND pgs.SeasonKey = @SeasonEndKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonEndKey
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