CREATE PROCEDURE dbo.TransferInASpecifiedPlayer
(
	@SeasonKey INT = NULL,
	@SpecifiedPlayerKey INT,
	@PlayerToRemoveKey INT,
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
	@PlayerToRemoveCost INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@PlayerToAddPoints INT,
	@SpecifiedPlayerCost INT,
	@PlayerToAddName VARCHAR(100),
	@PlayerToChangeName VARCHAR(100),
	@Loop INT,
	@Cnt INT;

	DECLARE @MaxGoalkeepers INT = 2,
	@MaxDefendersAndMidfielders INT = 5,
	@MaxForwards INT = 3;

	IF OBJECT_ID('tempdb..#CurrentSquad') IS NOT NULL
		DROP TABLE #CurrentSquad;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	SELECT my.*, pa.PlayerPositionKey, pa.TeamKey, pcs.TotalPoints
	INTO #CurrentSquad
	FROM dbo.MyTeam my
	INNER JOIN dbo.DimPlayerAttribute pa
	ON my.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON my.PlayerKey = pcs.PlayerKey
	WHERE my.SeasonKey = @SeasonKey
	AND my.GameweekKey = @GameweekEnd;

	--Get current cost of player to be moved into the squad
	SELECT @SpecifiedPlayerCost = gws.Cost
	FROM dbo.FactPlayerGameweekStatus gws
	WHERE gws.PlayerKey = @SpecifiedPlayerKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd;

	--Get current cost of player to be moved out of the squad
	SELECT @PlayerToRemoveCost = gws.Cost
	FROM dbo.FactPlayerGameweekStatus gws
	WHERE gws.PlayerKey = @PlayerToRemoveKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd;

	SELECT @SpecifiedPlayerCost AS SpecifiedPlayerCost;

	--Initial update to transfer player in and one player out
	UPDATE cs
	SET PlayerKey = @SpecifiedPlayerKey, Cost = @SpecifiedPlayerCost
	FROM #CurrentSquad cs
	INNER JOIN dbo.FactPlayerGameweekStatus gws
	ON cs.PlayerKey = gws.PlayerKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd
	WHERE cs.PlayerKey = @PlayerToRemoveKey;

	SELECT 'Before';

	SELECT p.PlayerName, cs.*
	FROM #CurrentSquad cs
	INNER JOIN dbo.DimPlayer p
	ON cs.PlayerKey = p.PlayerKey
	ORDER BY PlayerPositionKey, TotalPoints DESC;

	SELECT @TotalCost = SUM(Cost)
	FROM #CurrentSquad;

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #CurrentSquad;

	IF @Debug=1
		SELECT @TotalCost AS TotalCost;

	--Get how much needed to save to get within budget
	SELECT @Overspend = @TotalCost - 1000;
	SELECT @Overspend AS Overspend;

	SELECT @Loop = 1;
	SELECT @Cnt = 1;

	WHILE @Overspend > 0
	BEGIN	

		IF @Debug=1
		BEGIN

			SELECT @Loop AS [Loop];

			SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
			FROM #CurrentSquad cs;

			SELECT ph.PlayerKey,
			pa.PlayerPositionKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			AND ph.PlayerKey <> @SpecifiedPlayerKey
			AND ph.PlayerKey <> @PlayerToRemoveKey
			GROUP BY ph.PlayerKey, pa.PlayerPositionKey
			HAVING SUM(ph.TotalPoints) > 0
			ORDER BY pa.PlayerPositionKey, ph.PlayerKey;

			;WITH CurrentTeam AS
			(
				SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
				FROM #CurrentSquad cs
			)
			,PlayerPointsSummed AS
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
				AND ph.PlayerKey <> @SpecifiedPlayerKey
				AND ph.PlayerKey <> @PlayerToRemoveKey
				GROUP BY ph.PlayerKey, pa.PlayerPositionKey
				HAVING SUM(ph.TotalPoints) > 0
			)
			--PlayersRanked AS
			--(
			SELECT ct.PlayerKey AS CurrentPlayerKey,
			cp.PlayerName AS CurrentPlayerName,
			p.PlayerKey AS NewPlayerKey,
			p.PlayerName AS NewPlayerName,  
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			ct.Cost AS CurrentPlayerCost,
			pgs.Cost AS NewPlayerCost,
			ct.TotalPoints AS CurrentPlayerTotalPoints,
			pps.TotalPoints AS NewPlayerTotalPoints,
			(ct.TotalPoints - pps.TotalPoints) AS DiffPoints,
			(pgs.Cost - ct.Cost) AS DiffCost,
			--ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			ROW_NUMBER() OVER (ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank,
			ct.Cost - @Overspend AS NewPlayerMaxCost
			FROM PlayerPointsSummed pps
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			INNER JOIN CurrentTeam ct
			ON pps.PlayerPositionKey = ct.PlayerPositionKey
			AND ct.PlayerKey <> @SpecifiedPlayerKey
			AND ct.PlayerKey <> @PlayerToRemoveKey
			INNER JOIN dbo.DimPlayer cp
			ON ct.PlayerKey = cp.PlayerKey
			WHERE pgs.Cost < ct.Cost - @Overspend
			AND pps.TotalPoints <= ct.TotalPoints - 10
			AND NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pps.PlayerKey
			);


			;WITH CurrentTeam AS
			(
				SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
				FROM #CurrentSquad cs
			)
			,PlayerPointsSummed AS
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
				AND ph.PlayerKey <> @SpecifiedPlayerKey
				AND ph.PlayerKey <> @PlayerToRemoveKey
				GROUP BY ph.PlayerKey, pa.PlayerPositionKey
				HAVING SUM(ph.TotalPoints) > 0
			),
			PlayersRanked AS
			(
				SELECT ct.PlayerKey AS CurrentPlayerKey,
				cp.PlayerName AS CurrentPlayerName,
				p.PlayerKey AS NewPlayerKey,
				p.PlayerName AS NewPlayerName,  
				pa.PlayerPositionKey,
				pp.PlayerPositionShort,
				ct.Cost AS CurrentPlayerCost,
				pgs.Cost AS NewPlayerCost,
				ct.TotalPoints AS CurrentPlayerTotalPoints,
				pps.TotalPoints AS NewPlayerTotalPoints,
				(ct.TotalPoints - pps.TotalPoints) AS DiffPoints,
				(pgs.Cost - ct.Cost) AS DiffCost,
				--ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
				ROW_NUMBER() OVER (ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
				FROM PlayerPointsSummed pps
				INNER JOIN dbo.FactPlayerGameweekStatus pgs
				ON pps.PlayerKey = pgs.PlayerKey
				AND pgs.SeasonKey = @SeasonKey
				AND pgs.GameweekKey = @GameweekEnd
				INNER JOIN dbo.DimPlayer p
				ON pps.PlayerKey = p.PlayerKey
				INNER JOIN dbo.DimPlayerAttribute pa
				ON pps.PlayerKey = pa.PlayerKey
				AND pa.SeasonKey = @SeasonKey
				INNER JOIN dbo.DimPlayerPosition pp
				ON pa.PlayerPositionKey = pp.PlayerPositionKey
				INNER JOIN CurrentTeam ct
				ON pps.PlayerPositionKey = ct.PlayerPositionKey
				AND ct.PlayerKey <> @SpecifiedPlayerKey
				AND ct.PlayerKey <> @PlayerToRemoveKey
				INNER JOIN dbo.DimPlayer cp
				ON ct.PlayerKey = cp.PlayerKey
				WHERE pgs.Cost < ct.Cost - @Overspend
				AND pps.TotalPoints <= ct.TotalPoints - 10
				AND NOT EXISTS
				(
					SELECT 1
					FROM #CurrentSquad
					WHERE PlayerKey = pps.PlayerKey
				)
			)
			--NewPotentialPlayerRankedByTotalPoints AS
			--(
			SELECT NewPlayerKey, 
			NewPlayerName,
			NewPlayerCost,
			CurrentPlayerKey,
			CurrentPlayerName,
			CurrentPlayerCost,
			CurrentPlayerTotalPoints,
			NewPlayerTotalPoints,
			ROW_NUMBER() OVER (ORDER BY DiffPoints, NewPlayerKey) AS TotalPointsRank
			FROM PlayersRanked pr
			WHERE NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pr.NewPlayerKey
			)

		END
		
		--Get player to move out and player to move into the squad based on cost and points
		;WITH CurrentTeam AS
		(
			SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
			FROM #CurrentSquad cs
		)
		,PlayerPointsSummed AS
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
				AND ph.PlayerKey <> @SpecifiedPlayerKey
				AND ph.PlayerKey <> @PlayerToRemoveKey
				GROUP BY ph.PlayerKey, pa.PlayerPositionKey
				HAVING SUM(ph.TotalPoints) > 0
		),
		PlayersRanked AS
		(
			SELECT ct.PlayerKey AS CurrentPlayerKey,
			cp.PlayerName AS CurrentPlayerName,
			p.PlayerKey AS NewPlayerKey,
			p.PlayerName AS NewPlayerName,  
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			ct.Cost AS CurrentPlayerCost,
			pgs.Cost AS NewPlayerCost,
			ct.TotalPoints AS CurrentPlayerTotalPoints,
			pps.TotalPoints AS NewPlayerTotalPoints,
			(ct.TotalPoints - pps.TotalPoints) AS DiffPoints,
			(pgs.Cost - ct.Cost) AS DiffCost,
			--ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			ROW_NUMBER() OVER (ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
			FROM PlayerPointsSummed pps
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pgs.SeasonKey = @SeasonKey
			AND pgs.GameweekKey = @GameweekEnd
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			INNER JOIN CurrentTeam ct
			ON pps.PlayerPositionKey = ct.PlayerPositionKey
			AND ct.PlayerKey <> @SpecifiedPlayerKey
			AND ct.PlayerKey <> @PlayerToRemoveKey
			INNER JOIN dbo.DimPlayer cp
			ON ct.PlayerKey = cp.PlayerKey
			WHERE pgs.Cost < ct.Cost - @Overspend
			AND pps.TotalPoints <= ct.TotalPoints - 10
			AND NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pps.PlayerKey
			)
		),
		NewPotentialPlayerRankedByTotalPoints AS
		(
			SELECT NewPlayerKey, 
			NewPlayerName,
			NewPlayerCost,
			CurrentPlayerKey,
			CurrentPlayerName,
			CurrentPlayerCost,
			CurrentPlayerTotalPoints,
			NewPlayerTotalPoints,
			ROW_NUMBER() OVER (ORDER BY DiffPoints, NewPlayerKey) AS TotalPointsRank
			FROM PlayersRanked pr
			WHERE NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pr.NewPlayerKey
			)
		)
		SELECT @PlayerKeyToChange = CurrentPlayerKey, 
		@PlayerToChangeCost = CurrentPlayerCost, 
		@PlayerKeyToAdd = NewPlayerKey, 
		@PlayerToAddCost = NewPlayerCost, 
		@PlayerToAddPoints = NewPlayerTotalPoints,
		@PlayerToAddName = NewPlayerName,
		@PlayerToChangeName = CurrentPlayerName
		FROM NewPotentialPlayerRankedByTotalPoints
		WHERE TotalPointsRank = 1;

		IF @Debug=1
			SELECT @PlayerKeyToChange AS PlayerKeyToChange, 
			@PlayerToChangeName AS PlayerToChangeName,
			@PlayerToChangeCost AS PlayerToChangeCost, 
			@PlayerKeyToAdd AS PlayerKeyToAdd, 
			@PlayerToChangeName AS PlayerToChangeName,
			@PlayerToAddCost AS PlayerToAddCost;

		--Update Old player with new player in temp table
		UPDATE #CurrentSquad
		SET PlayerKey = @PlayerKeyToAdd,
		Cost = @PlayerToAddCost,
		TotalPoints = @PlayerToAddPoints
		WHERE PlayerKey = @PlayerKeyToChange;		

		SELECT @PlayerToChangeName AS PlayerToChangeName, @PlayerToAddName AS PlayerToAddName;

		SELECT @Overspend = @Overspend - (@PlayerToChangeCost - @PlayerToAddCost);
		SELECT @Overspend AS Overspend;

		SELECT @Loop = @Loop + 1;
		SELECT @Cnt = @Cnt + 1;

		IF @Cnt > 10
			SET @Overspend = 0;

	END

	SELECT 'After';

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #CurrentSquad;

	SELECT p.PlayerName, cs.*
	FROM #CurrentSquad cs
	INNER JOIN dbo.DimPlayer p
	ON cs.PlayerKey = p.PlayerKey
	ORDER BY PlayerPositionKey, TotalPoints DESC;

	SELECT 
	@SeasonKey AS SeasonKey,
	@GameweekStart AS GameweekStart,
	@GameweekEnd AS GameweekEnd,
	PlayerKey, 
	PlayerPositionKey,
	Cost,
	TotalPoints
	FROM #CurrentSquad;

	--MERGE INTO dbo.MyTeam AS Target 
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
	--	FROM #CurrentSquad
	--)
	--AS Source (SeasonKey, GameweekStart, GameweekEnd, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	--ON Source.SeasonKey = Target.SeasonKey
	--AND Source.PlayerKey = Target.PlayerKey
	----AND Source.PlayerPositionKey = Target.PlayerPositionKey
	--WHEN NOT MATCHED BY TARGET THEN
	--INSERT (SeasonKey, PlayerKey, Cost, IsPlay)
	--VALUES (Source.SeasonKey, Source.PlayerKey, Source.Cost, Source.IsPlay)
	--WHEN NOT MATCHED BY SOURCE THEN
	--DELETE;

END