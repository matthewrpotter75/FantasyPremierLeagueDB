CREATE PROCEDURE dbo.TransferInSpecifiedPlayers
(
	@SeasonKey INT = NULL,
	@SpecifiedPlayerKey INT = NULL,
	@PlayerToRemoveKey INT = NULL,
	@PlayersToChangeKeys VARCHAR(100) = '',
	@MaxNumberOfTransfers INT = 1,	
	@GameweekStart INT,
	@GameweekEnd INT,
	@TotalPointsRange INT = 10,
	@Debug BIT = 0,
	@TimerDebug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TotalCost INT,
	@Overspend INT,
	@PlayerKeyToChange INT,
	@PlayerToChangeCost INT,
	--@PlayerToRemoveCost INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@PlayerToAddPoints INT,
	--@SpecifiedPlayerCost INT,
	--@SpecifiedPlayerTotalPoints INT,
	@PlayerToAddName VARCHAR(100),
	@PlayerToChangeName VARCHAR(100),
	@PlayersToChangeCost INT,
	@Delimiter NVARCHAR(4) = ',',
	@SPTIPlayerKeyToChange INT,
	@Time DATETIME,
	@StartTime DATETIME;

	DECLARE @MaxGoalkeepers INT = 2,
	@MaxDefendersAndMidfielders INT = 5,
	@MaxForwards INT = 3;

	IF OBJECT_ID('tempdb..#CurrentSquad') IS NOT NULL
		DROP TABLE #CurrentSquad;

	IF OBJECT_ID('tempdb..#PlayersToAdd') IS NOT NULL
		DROP TABLE #PlayersToAdd;

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='TransferInSpecifiedPlayers Starting', @Time=@time OUTPUT;
		SET @time = GETDATE();
		SET @StartTime = @time;
	END

	CREATE TABLE #PlayersToAdd
	(
		CurrentPlayerKey INT, 
		CurrentPlayerCost INT, 
		CurrentPlayerName VARCHAR(100),
		CurrentPlayerTotalPoints INT,
		NewPlayerKey INT, 
		NewPlayerCost INT, 
		NewPlayerTotalPoints INT,
		NewPlayerName VARCHAR(100)
	);

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @PlayersToChangeTable TABLE (Id INT IDENTITY(1,1), PlayerKey INT, PlayerPositionKey INT, PlayerName VARCHAR(100), Cost INT, TotalPoints INT)

	INSERT INTO @PlayersToChangeTable
	(PlayerKey, PlayerPositionKey, PlayerName, Cost, TotalPoints)
	SELECT p.PlayerKey, pa.PlayerPositionKey, p.PlayerName, pcs.Cost, pcs.TotalPoints
	FROM dbo.fnSplit(@PlayersToChangeKeys, @Delimiter) sp
	INNER JOIN dbo.DimPlayer p
	ON sp.Term = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON p.PlayerKey = pcs.PlayerKey;

	IF (SELECT COUNT(1) FROM @PlayersToChangeTable) > 0
	BEGIN

		SELECT @MaxNumberOfTransfers = MAX(Id) FROM @PlayersToChangeTable;
		SELECT @PlayersToChangeCost = SUM(Cost) FROM @PlayersToChangeTable;

		IF @Debug=1
			SELECT @PlayersToChangeCost AS PlayersToChangeCost;

	END

	CREATE TABLE #CurrentSquad
	(
		Id INT IDENTITY(1,1),
		SeasonKey INT,
		GameweekKey INT,
		PlayerKey INT,
		Cost INT,
		IsPlay BIT,
		IsCaptain BIT,
		PlayerPositionKey INT,
		TeamKey INT,
		TotalPoints INT
	);

	INSERT INTO #CurrentSquad
	(SeasonKey, GameweekKey, PlayerKey, Cost, IsPlay, IsCaptain, PlayerPositionKey, TeamKey, TotalPoints)
	SELECT my.*, pa.PlayerPositionKey, pa.TeamKey, pcs.TotalPoints
	FROM dbo.MyTeam my
	INNER JOIN dbo.DimPlayerAttribute pa
	ON my.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON my.PlayerKey = pcs.PlayerKey
	WHERE my.SeasonKey = @SeasonKey
	AND my.GameweekKey = @GameweekEnd;

	IF @Debug=1
	BEGIN
	
		SELECT 'Initial squad';

		SELECT p.PlayerName, cs.*
		FROM #CurrentSquad cs
		INNER JOIN dbo.DimPlayer p
		ON cs.PlayerKey = p.PlayerKey
		ORDER BY PlayerPositionKey, TotalPoints DESC;

		SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
		FROM #CurrentSquad;

	END

	IF @SpecifiedPlayerKey IS NOT NULL
	BEGIN

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='Pre SpecifiedPlayerTransferIn', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

		EXEC dbo.SpecifiedPlayerTransferIn
		@SeasonKey = @SeasonKey,
		@SpecifiedPlayerKey = @SpecifiedPlayerKey,
		@PlayerToRemoveKey = @PlayerToRemoveKey,
		@PlayersToChangeKeys = @PlayersToChangeKeys,
		@GameweekStart = @GameweekStart,
		@GameweekEnd = @GameweekEnd,
		@Overspend = @Overspend,
		@Debug = @Debug,
		@TimerDebug = @TimerDebug,
		@PlayerKeyToChange = @SPTIPlayerKeyToChange OUTPUT;

		IF @TimerDebug = 1
		BEGIN
			EXEC dbo.OutputStepAndTimeText @Step='Post SpecifiedPlayerTransferIn', @Time=@time OUTPUT;
			SET @time = GETDATE();
		END

	END

	SELECT @TotalCost = SUM(Cost)
	FROM #CurrentSquad;

	IF @Debug=1
	BEGIN

		--SELECT @SPTIPlayerKeyToChange AS SPTIPlayerKeyToChange;

		SELECT 'Before';

		SELECT p.PlayerName, cs.*
		FROM #CurrentSquad cs
		INNER JOIN dbo.DimPlayer p
		ON cs.PlayerKey = p.PlayerKey
		ORDER BY PlayerPositionKey, TotalPoints DESC;

		SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
		FROM #CurrentSquad;

	END

	--Get how much needed to save to get within budget
	SELECT @Overspend = @TotalCost - 1000;

	IF @Debug=1
	BEGIN

		SELECT @TotalCost AS TotalCost;
		SELECT @Overspend AS Overspend;

		SELECT 'PlayersToChangeTable';

		SELECT *
		FROM @PlayersToChangeTable;

	END

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='Pre CTE', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END

	IF @PlayersToChangeKeys = ''
	BEGIN
		
		IF @Debug = 1
		BEGIN

			SELECT 'CurrentPlayers branch';

			--Get player to move out and player to move into the squad based on cost and points
			;WITH CurrentTeam AS
			(
				SELECT Id, PlayerKey, PlayerPositionKey, Cost, TotalPoints
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
				AND ph.PlayerKey <> ISNULL(@SpecifiedPlayerKey, 0)
				AND ph.PlayerKey <> ISNULL(@PlayerToRemoveKey, 0)
				GROUP BY ph.PlayerKey, pa.PlayerPositionKey
				HAVING SUM(ph.TotalPoints) > 0
			)
			--PlayersRanked AS
			--(
			SELECT ct.Id,
			ct.PlayerKey AS CurrentPlayerKey,
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
			ROW_NUMBER() OVER (PARTITION BY ct.Id ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
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
			INNER JOIN dbo.DimPlayer cp
			ON ct.PlayerKey = cp.PlayerKey
			--WHERE pgs.Cost < ct.Cost - @Overspend
			WHERE pps.TotalPoints >= ct.TotalPoints - @TotalPointsRange
			AND ct.PlayerKey <> ISNULL(@SpecifiedPlayerKey,0)
			AND ct.PlayerKey <> ISNULL(@PlayerToRemoveKey,0)
			AND NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pps.PlayerKey
			);

		END

		--Get player to move out and player to move into the squad based on cost and points
		;WITH CurrentTeam AS
		(
			SELECT Id, PlayerKey, PlayerPositionKey, Cost, TotalPoints
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
			AND ph.PlayerKey <> ISNULL(@SpecifiedPlayerKey, 0)
			AND ph.PlayerKey <> ISNULL(@PlayerToRemoveKey, 0)
			GROUP BY ph.PlayerKey, pa.PlayerPositionKey
			HAVING SUM(ph.TotalPoints) > 0
		),
		PlayersRanked AS
		(
			SELECT ct.Id,
			ct.PlayerKey AS CurrentPlayerKey,
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
			ROW_NUMBER() OVER (PARTITION BY ct.Id ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
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
			INNER JOIN dbo.DimPlayer cp
			ON ct.PlayerKey = cp.PlayerKey
			--WHERE pgs.Cost < ct.Cost - @Overspend
			WHERE pps.TotalPoints >= ct.TotalPoints - @TotalPointsRange
			AND ct.PlayerKey <> ISNULL(@SpecifiedPlayerKey,0)
			AND ct.PlayerKey <> ISNULL(@PlayerToRemoveKey,0)
			AND NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pps.PlayerKey
			)
		),
		AnchorPlayer AS
		(
			SELECT p.Id,
			ROW_NUMBER() OVER (PARTITION BY p.CurrentPlayerKey ORDER BY PlayerRank) AS RowNum,
			p.PlayerPositionKey,
			p.CurrentPlayerKey,
			p.CurrentPlayerName,
			cpcs.Cost AS CurrentPlayerCost,
			cpcs.TotalPoints AS CurrentPlayerTotalPoints,
			p.NewPlayerKey,
			p.NewPlayerName,
			pcs.Cost AS NewPlayerCost,
			pcs.TotalPoints AS NewPlayerTotalPoints,
			pcs.Cost AS CostSummed,
			pcs.TotalPoints AS PointsSummed,
			1 AS RecursionLevel
			FROM PlayersRanked p
			INNER JOIN dbo.FactPlayerCurrentStats cpcs
			ON p.CurrentPlayerKey = cpcs.PlayerKey
			INNER JOIN dbo.FactPlayerCurrentStats pcs
			ON p.NewPlayerKey = pcs.PlayerKey
			WHERE p.Id = 1
			AND p.PlayerRank <= 20

			UNION ALL

			SELECT p.Id,
			ap.RowNum,
			p.PlayerPositionKey,
			p.CurrentPlayerKey,
			p.CurrentPlayerName,
			cpcs.Cost AS CurrentPlayerCost,
			cpcs.TotalPoints AS CurrentPlayerTotalPoints,
			p.NewPlayerKey,
			p.NewPlayerName,
			pcs.Cost AS NewPlayerCost,
			pcs.TotalPoints AS NewPlayerTotalPoints,
			(pcs.Cost + ap.NewPlayerCost) AS CostSummed,
			(pcs.TotalPoints + ap.PointsSummed) AS PointsSummed,
			(ap.RecursionLevel + 1) AS RecursionLevel
			FROM PlayersRanked p
			INNER JOIN dbo.FactPlayerCurrentStats cpcs
			ON p.CurrentPlayerKey = cpcs.PlayerKey
			INNER JOIN dbo.FactPlayerCurrentStats pcs
			ON p.NewPlayerKey = pcs.PlayerKey
			CROSS APPLY AnchorPlayer ap
			WHERE p.Id = (ap.RecursionLevel + 1)
			AND p.CurrentPlayerKey <> ap.CurrentPlayerKey
			AND p.NewPlayerKey <> ap.NewPlayerKey
			AND (pcs.Cost + ap.NewPlayerCost) <= @PlayersToChangeCost
			AND (ap.RecursionLevel + 1) <= @MaxNumberOfTransfers
			AND p.PlayerRank <= 20
		),
		BestCombinationsRanked AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY RecursionLevel, CurrentPlayerKey ORDER BY PointsSummed DESC) AS CombinationRank
			FROM AnchorPlayer
			WHERE RowNum = 1
		)
		INSERT INTO #PlayersToAdd
		(CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName)
		SELECT CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName
		FROM BestCombinationsRanked
		WHERE CombinationRank = 1;

	END
	ELSE
	BEGIN

		IF @Debug=1
		BEGIN

			SELECT 'PlayersToChangeTable branch';

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
				AND ph.PlayerKey <> ISNULL(@SpecifiedPlayerKey, 0)
				AND ph.PlayerKey <> ISNULL(@PlayerToRemoveKey, 0)
				GROUP BY ph.PlayerKey, pa.PlayerPositionKey
				HAVING SUM(ph.TotalPoints) > 0
			)
			--PlayersRanked AS
			--(
			SELECT ct.Id,
			ct.PlayerKey AS CurrentPlayerKey,
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
			ROW_NUMBER() OVER (PARTITION BY ct.Id ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
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
			INNER JOIN @PlayersToChangeTable ct
			ON pps.PlayerPositionKey = ct.PlayerPositionKey
			INNER JOIN dbo.DimPlayer cp
			ON ct.PlayerKey = cp.PlayerKey
			--WHERE pgs.Cost < ct.Cost - @Overspend
			WHERE pps.TotalPoints >= ct.TotalPoints - @TotalPointsRange
			AND ct.PlayerKey <> ISNULL(@SpecifiedPlayerKey,0)
			AND ct.PlayerKey <> ISNULL(@PlayerToRemoveKey,0)
			AND NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pps.PlayerKey
			);

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
			AND ph.PlayerKey <> ISNULL(@SpecifiedPlayerKey, 0)
			AND ph.PlayerKey <> ISNULL(@PlayerToRemoveKey, 0)
			GROUP BY ph.PlayerKey, pa.PlayerPositionKey
			HAVING SUM(ph.TotalPoints) > 0
		),
		PlayersRanked AS
		(
			SELECT ct.Id,
			ct.PlayerKey AS CurrentPlayerKey,
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
			ROW_NUMBER() OVER (PARTITION BY ct.Id ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
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
			INNER JOIN @PlayersToChangeTable ct
			ON pps.PlayerPositionKey = ct.PlayerPositionKey
			INNER JOIN dbo.DimPlayer cp
			ON ct.PlayerKey = cp.PlayerKey
			--WHERE pgs.Cost < ct.Cost - @Overspend
			WHERE pps.TotalPoints >= ct.TotalPoints - @TotalPointsRange
			AND ct.PlayerKey <> ISNULL(@SpecifiedPlayerKey,0)
			AND ct.PlayerKey <> ISNULL(@PlayerToRemoveKey,0)
			AND NOT EXISTS
			(
				SELECT 1
				FROM #CurrentSquad
				WHERE PlayerKey = pps.PlayerKey
			)
		),
		AnchorPlayer AS
		(
			SELECT p.Id,
			ROW_NUMBER() OVER (PARTITION BY p.CurrentPlayerKey ORDER BY PlayerRank) AS RowNum,
			p.PlayerPositionKey,
			p.CurrentPlayerKey,
			p.CurrentPlayerName,
			cpcs.Cost AS CurrentPlayerCost,
			cpcs.TotalPoints AS CurrentPlayerTotalPoints,
			p.NewPlayerKey,
			p.NewPlayerName,
			pcs.Cost AS NewPlayerCost,
			pcs.TotalPoints AS NewPlayerTotalPoints,
			pcs.Cost AS CostSummed,
			pcs.TotalPoints AS PointsSummed,
			1 AS RecursionLevel
			FROM PlayersRanked p
			INNER JOIN dbo.FactPlayerCurrentStats cpcs
			ON p.CurrentPlayerKey = cpcs.PlayerKey
			INNER JOIN dbo.FactPlayerCurrentStats pcs
			ON p.NewPlayerKey = pcs.PlayerKey
			WHERE p.Id = 1
			AND p.PlayerRank <= 20

			UNION ALL

			SELECT p.Id,
			ap.RowNum,
			p.PlayerPositionKey,
			p.CurrentPlayerKey,
			p.CurrentPlayerName,
			cpcs.Cost AS CurrentPlayerCost,
			cpcs.TotalPoints AS CurrentPlayerTotalPoints,
			p.NewPlayerKey,
			p.NewPlayerName,
			pcs.Cost AS NewPlayerCost,
			pcs.TotalPoints AS NewPlayerTotalPoints,
			(pcs.Cost + ap.NewPlayerCost) AS CostSummed,
			(pcs.TotalPoints + ap.PointsSummed) AS PointsSummed,
			(ap.RecursionLevel + 1) AS RecursionLevel
			FROM PlayersRanked p
			INNER JOIN dbo.FactPlayerCurrentStats cpcs
			ON p.CurrentPlayerKey = cpcs.PlayerKey
			INNER JOIN dbo.FactPlayerCurrentStats pcs
			ON p.NewPlayerKey = pcs.PlayerKey
			CROSS APPLY AnchorPlayer ap
			WHERE p.Id = (ap.RecursionLevel + 1)
			AND p.CurrentPlayerKey <> ap.CurrentPlayerKey
			AND p.NewPlayerKey <> ap.NewPlayerKey
			AND (pcs.Cost + ap.NewPlayerCost) <= @PlayersToChangeCost
			AND (ap.RecursionLevel + 1) <= @MaxNumberOfTransfers
			AND p.PlayerRank <= 20
		),
		BestCombinationsRanked AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY RecursionLevel, CurrentPlayerKey ORDER BY PointsSummed DESC) AS CombinationRank
			FROM AnchorPlayer
			WHERE RowNum = 1
		)
		INSERT INTO #PlayersToAdd
		(CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName)
		SELECT CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName
		FROM BestCombinationsRanked
		WHERE CombinationRank = 1;

	END

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='Post CTE', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END

	--Update Old player with new player in temp table
	UPDATE cs
	SET PlayerKey = pta.NewPlayerKey,
	Cost = NewPlayerCost,
	TotalPoints = NewPlayerTotalPoints
	FROM #CurrentSquad cs
	INNER JOIN #PlayersToAdd pta
	ON cs.PlayerKey = pta.CurrentPlayerKey;	

	IF @Debug=1
	BEGIN

		SELECT 'PlayersToAdd';

		SELECT *
		FROM #PlayersToAdd;

	END

	SELECT @PlayerToAddCost = SUM(NewPlayerCost) FROM #PlayersToAdd;
	SELECT @PlayerToChangeCost = SUM(CurrentPlayerCost) FROM #PlayersToAdd;

	SELECT @Overspend = @Overspend - (@PlayerToChangeCost - @PlayerToAddCost);

	IF @Debug=1
	BEGIN

		SELECT @PlayerToAddCost AS PlayerToAddCost, @PlayerToChangeCost AS PlayerToChangeCost;

		SELECT @Overspend AS Overspend;

		SELECT 'After';

		SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
		FROM #CurrentSquad;

	END

	--Final Current Squad
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

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='Post Update', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='TransferInSpecifiedPlayers Ending', @Time=@StartTime OUTPUT;
	END

END