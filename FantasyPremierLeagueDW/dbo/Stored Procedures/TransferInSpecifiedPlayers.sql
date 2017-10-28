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
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TotalCost INT,
	@Overspend INT,
	@PlayerKeyToChange INT,
	@PlayerToChangeCost INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@PlayerToAddPoints INT,
	@PlayerToAddName VARCHAR(100),
	@PlayerToChangeName VARCHAR(100),
	@PlayersToChangeCost INT,
	@Delimiter NVARCHAR(4) = ',',
	@SPTIPlayerKeyToChange INT,
	@Time DATETIME,
	@StartTime DATETIME,
	@NewPlayerKeyPath VARCHAR(100),
	@CurrentPlayerKeyPath VARCHAR(100),
	@i INT;

	IF OBJECT_ID('tempdb..#CurrentSquad') IS NOT NULL
		DROP TABLE #CurrentSquad;

	IF OBJECT_ID('tempdb..#PlayersToAdd') IS NOT NULL
		DROP TABLE #PlayersToAdd;

	IF OBJECT_ID('tempdb..#PlayerPointsCombinations') IS NOT NULL
		DROP TABLE #PlayerPointsCombinations;

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

	DECLARE @PlayersToChangeTable UDTPlayersToChangeTable;

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

	CREATE INDEX IX_CurrentSquad_PlayerKey ON #CurrentSquad (PlayerKey);

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
		@TimerDebug = @TimerDebug;

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

		SELECT @PlayersToChangeCost AS PlayersToChangeCost, @Overspend AS Overspend, @PlayersToChangeCost - @Overspend AS TotalAvailableCost;

	END

	CREATE TABLE #PlayerPointsCombinations
	(
		Id INT,
		CurrentPlayerKeyPath VARCHAR(100),
		NewPlayerKeyPath VARCHAR(100),
		RowNum INT,
		PlayerPositionKey INT,
		CurrentPlayerKey INT,
		CurrentPlayerName VARCHAR(100),
		CurrentPlayerCost INT,
		CurrentPlayerTotalPoints INT,
		NewPlayerKey INT,
		NewPlayerName VARCHAR(100),
		NewPlayerCost INT,
		NewPlayerTotalPoints INT,		
		CurrentPlayerCostSummed INT,
		NewPlayerCostSummed INT,
		CurrentPlayerPointsSummed INT,
		NewPlayerPointsSummed INT,
		RecursionLevel INT,
		DiffPoints INT,
		DiffCost INT,
		CombinationRank INT
	);

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='Pre CTE', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END

	IF @PlayersToChangeKeys = ''
	BEGIN

		INSERT INTO @PlayersToChangeTable
		(PlayerKey, PlayerPositionKey, PlayerName, Cost, TotalPoints)
		SELECT cs.PlayerKey, cs.PlayerPositionKey, p.PlayerName, cs.Cost, cs.TotalPoints
		FROM #CurrentSquad cs
		INNER JOIN dbo.DimPlayer p
		ON cs.PlayerKey = p.PlayerKey
		ORDER BY PlayerPositionKey, Cost, TotalPoints;

		
		IF @Debug = 1
		BEGIN

			SELECT 'CurrentPlayers branch';

			SELECT @SeasonKey AS SeasonKey, 
			@SpecifiedPlayerKey AS SpecifiedPlayerKey, 
			@PlayerToRemoveKey AS PlayerToRemoveKey, 
			@PlayersToChangeKeys AS PlayersToChangeKeys, 
			@MaxNumberOfTransfers AS MaxNumberOfTransfers, 
			@GameweekStart AS GameweekStart, 
			@GameweekEnd AS GameweekEnd, 
			@TotalPointsRange AS TotalPointsRange, 
			@PlayersToChangeCost AS PlayersToChangeCost, 
			@Overspend AS Overspend;

			SELECT *
			FROM dbo.fnGetPlayersRankedAll(@SeasonKey, @SpecifiedPlayerKey, @PlayerToRemoveKey, @PlayersToChangeKeys, @MaxNumberOfTransfers, @GameweekStart, @GameweekEnd, @TotalPointsRange, @PlayersToChangeCost, @Overspend, @PlayersToChangeTable);

		END

		--Get players to move out and players to move into the squad based on cost and points
		INSERT INTO #PlayerPointsCombinations
		SELECT *
		FROM dbo.fnGetPlayersRankedAll(@SeasonKey, @SpecifiedPlayerKey, @PlayerToRemoveKey, @PlayersToChangeKeys, @MaxNumberOfTransfers, @GameweekStart, @GameweekEnd, @TotalPointsRange, @PlayersToChangeCost, @Overspend, @PlayersToChangeTable);

	END
	ELSE
	BEGIN

		IF @Debug=1
		BEGIN

			SELECT 'PlayersToChangeTable branch';

			SELECT @SeasonKey AS SeasonKey, 
			@SpecifiedPlayerKey AS SpecifiedPlayerKey, 
			@PlayerToRemoveKey AS PlayerToRemoveKey, 
			@PlayersToChangeKeys AS PlayersToChangeKeys, 
			@MaxNumberOfTransfers AS MaxNumberOfTransfers, 
			@GameweekStart AS GameweekStart, 
			@GameweekEnd AS GameweekEnd, 
			@TotalPointsRange AS TotalPointsRange, 
			@PlayersToChangeCost AS PlayersToChangeCost, 
			@Overspend AS Overspend;

			SELECT *
			FROM dbo.fnGetPlayersRanked(@SeasonKey, @SpecifiedPlayerKey, @PlayerToRemoveKey, @PlayersToChangeKeys, @MaxNumberOfTransfers, @GameweekStart, @GameweekEnd, @TotalPointsRange, @PlayersToChangeCost, @Overspend, @PlayersToChangeTable);

		END

		--Get players to move out and players to move into the squad based on cost and points
		INSERT INTO #PlayerPointsCombinations
		SELECT *
		FROM dbo.fnGetPlayersRanked(@SeasonKey, @SpecifiedPlayerKey, @PlayerToRemoveKey, @PlayersToChangeKeys, @MaxNumberOfTransfers, @GameweekStart, @GameweekEnd, @TotalPointsRange, @PlayersToChangeCost, @Overspend, @PlayersToChangeTable);
		
	END

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='Post CTE', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END


	IF @Debug=1
	BEGIN
		
		SELECT *
		FROM #PlayerPointsCombinations
		WHERE CombinationRank = 1;

	END

	CREATE INDEX IX_PlayerPointsCombinations_RecursionLevel_PlayerKeyPath ON #PlayerPointsCombinations (RecursionLevel, NewPlayerKeyPath);

	SELECT @CurrentPlayerKeyPath = CurrentPlayerKeyPath, @NewPlayerKeyPath = NewPlayerKeyPath
	FROM #PlayerPointsCombinations
	WHERE CombinationRank = 1
	AND RecursionLevel = @MaxNumberOfTransfers;

	;WITH PlayersToTransfer AS
	(
		SELECT CurrentPlayer.Ordinal, CurrentPlayerKey, NewPlayerKey
		FROM
		(
			SELECT Ordinal, Term AS CurrentPlayerKey
			FROM dbo.fnSplit(@CurrentPlayerKeyPath,',')
		) CurrentPlayer
		INNER JOIN 
		(
			SELECT Ordinal, Term AS NewPlayerKey
			FROM dbo.fnSplit(@NewPlayerKeyPath,',')
		) NewPlayer
		ON CurrentPlayer.Ordinal = NewPlayer.Ordinal
	)
	INSERT INTO #PlayersToAdd
	(CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName)
	SELECT DISTINCT ppc.CurrentPlayerKey, ppc.CurrentPlayerCost, ppc.CurrentPlayerName, ppc.CurrentPlayerTotalPoints, ppc.NewPlayerKey, ppc.NewPlayerCost, ppc.NewPlayerTotalPoints, ppc.NewPlayerName
	FROM #PlayerPointsCombinations ppc
	INNER JOIN PlayersToTransfer ptt
	ON ppc.CurrentPlayerKey = ptt.CurrentPlayerKey
	AND ppc.NewPlayerKey = ptt.NewPlayerKey
	WHERE CHARINDEX(CAST(ppc.CurrentPlayerKey AS VARCHAR(10)),@CurrentPlayerKeyPath,1) > 0
	AND CHARINDEX(CAST(ppc.NewPlayerKey AS VARCHAR(10)),@NewPlayerKeyPath,1) > 0;

	IF @Debug=1
	BEGIN
		
		SELECT 'New PlayersToTransfer';

		SELECT CurrentPlayer.Ordinal, CurrentPlayerKey, NewPlayerKey
		FROM
		(
			SELECT Ordinal, Term AS CurrentPlayerKey
			FROM dbo.fnSplit(@CurrentPlayerKeyPath,',')
		) CurrentPlayer
		INNER JOIN 
		(
			SELECT Ordinal, Term AS NewPlayerKey
			FROM dbo.fnSplit(@NewPlayerKeyPath,',')
		) NewPlayer
		ON CurrentPlayer.Ordinal = NewPlayer.Ordinal;

		;WITH PlayersToTransfer AS
		(
			SELECT CurrentPlayer.Ordinal, CurrentPlayerKey, NewPlayerKey
			FROM
			(
				SELECT Ordinal, Term AS CurrentPlayerKey
				FROM dbo.fnSplit(@CurrentPlayerKeyPath,',')
			) CurrentPlayer
			INNER JOIN 
			(
				SELECT Ordinal, Term AS NewPlayerKey
				FROM dbo.fnSplit(@NewPlayerKeyPath,',')
			) NewPlayer
			ON CurrentPlayer.Ordinal = NewPlayer.Ordinal
		)
		--SELECT ppc.CurrentPlayerKey, ppc.CurrentPlayerCost, ppc.CurrentPlayerName, ppc.CurrentPlayerTotalPoints, ppc.NewPlayerKey, ppc.NewPlayerCost, ppc.NewPlayerTotalPoints, ppc.NewPlayerName
		SELECT ppc.*
		FROM #PlayerPointsCombinations ppc
		INNER JOIN PlayersToTransfer ptt
		ON ppc.CurrentPlayerKey = ptt.CurrentPlayerKey
		AND ppc.NewPlayerKey = ptt.NewPlayerKey
		WHERE CHARINDEX(CAST(ppc.CurrentPlayerKey AS VARCHAR(10)),@CurrentPlayerKeyPath,1) > 0
		AND CHARINDEX(CAST(ppc.NewPlayerKey AS VARCHAR(10)),@NewPlayerKeyPath,1) > 0;

	END

	--SET @i = @MaxNumberOfTransfers;

	--WHILE @i > 0
	--BEGIN

	--	IF @Debug=1
	--	BEGIN

	--		SELECT @NewPlayerKeyPath AS NewPlayerKeyPath;
		
	--		SELECT @i AS i, CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName
	--		FROM #PlayerPointsCombinations
	--		WHERE RecursionLevel = @i
	--		AND NewPlayerKeyPath = @NewPlayerKeyPath;		
		
	--	END

	--	INSERT INTO #PlayersToAdd
	--	(CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName)
	--	SELECT CurrentPlayerKey, CurrentPlayerCost, CurrentPlayerName, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerCost, NewPlayerTotalPoints, NewPlayerName
	--	FROM #PlayerPointsCombinations
	--	WHERE RecursionLevel = @i
	--	AND NewPlayerKeyPath = @NewPlayerKeyPath;

	--	SET @i = @i - 1;

	--	IF PATINDEX('%,%',REVERSE(@NewPlayerKeyPath)) > 0 AND @i > 0
	--		SELECT @NewPlayerKeyPath = LEFT(@NewPlayerKeyPath,LEN(@NewPlayerKeyPath) - PATINDEX('%,%',REVERSE(@NewPlayerKeyPath)));

	--END

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='#PlayersToAdd inserts', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END

	IF @Debug=1
	BEGIN

		SELECT 'PlayersToAdd';

	END

	SELECT *
	FROM #PlayersToAdd;

	--Update Old player with new player in temp table
	UPDATE cs
	SET PlayerKey = pta.NewPlayerKey,
	Cost = NewPlayerCost,
	TotalPoints = NewPlayerTotalPoints
	FROM #CurrentSquad cs
	INNER JOIN #PlayersToAdd pta
	ON cs.PlayerKey = pta.CurrentPlayerKey;	

	SELECT @PlayerToAddCost = SUM(NewPlayerCost) FROM #PlayersToAdd;
	SELECT @PlayerToChangeCost = SUM(CurrentPlayerCost) FROM #PlayersToAdd;

	SELECT @Overspend = @Overspend - (@PlayerToChangeCost - @PlayerToAddCost);

	IF @Debug=1
	BEGIN

		SELECT @PlayerToAddCost AS PlayerToAddCost, @PlayerToChangeCost AS PlayerToChangeCost;

		SELECT @Overspend AS Overspend;

		SELECT 'After';

	END

	SELECT SUM(Cost) AS TotalCost, SUM(TotalPoints) AS TotalPoints
	FROM #CurrentSquad;

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