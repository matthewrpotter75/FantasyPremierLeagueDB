CREATE PROCEDURE dbo.SpecifiedPlayerTransferIn
(
	@SeasonKey INT = NULL,
	@SpecifiedPlayerKey INT,
	@PlayerToRemoveKey INT,
	@PlayersToChangeKeys VARCHAR(100),
	@GameweekStart INT,
	@GameweekEnd INT,
	@Overspend INT,
	@Debug BIT = 0,
	@TimerDebug BIT = 0,
	@PlayerKeyToChange INT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PlayerToChangeCost INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@PlayerToAddPoints INT,
	@PlayerToAddName VARCHAR(100),
	@PlayerToChangeName VARCHAR(100),
	@SpecifiedPlayerCost INT,
	@SpecifiedPlayerTotalPoints INT,
	@PlayerToRemoveCost INT,
	@TotalCost INT,
	@Delimiter NVARCHAR(4) = ',',
	@time DATETIME;

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='SpecifiedPlayerTransferIn Starting', @Time=@time OUTPUT;
		SET @time = GETDATE();
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

	--Get current cost of player to be moved into the squad
	SELECT @SpecifiedPlayerCost = gws.Cost, @SpecifiedPlayerTotalPoints = gws.TotalPoints
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

	IF @Debug=1
		SELECT @SpecifiedPlayerCost AS SpecifiedPlayerCost, @PlayerToRemoveCost AS PlayerToRemoveCost;

	--Initial update to transfer player in and one player out
	UPDATE cs
	SET PlayerKey = @SpecifiedPlayerKey, Cost = @SpecifiedPlayerCost, TotalPoints = @SpecifiedPlayerTotalPoints
	FROM #CurrentSquad cs
	INNER JOIN dbo.FactPlayerGameweekStatus gws
	ON cs.PlayerKey = gws.PlayerKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd
	WHERE cs.PlayerKey = @PlayerToRemoveKey;

	--IF @Debug=1
	--BEGIN

	--	SELECT 'SpecifiedPlayerTransferIn Start';	

	--	SELECT p.PlayerName, cs.*
	--	FROM #CurrentSquad cs
	--	INNER JOIN dbo.DimPlayer p
	--	ON cs.PlayerKey = p.PlayerKey
	--	ORDER BY PlayerPositionKey, TotalPoints DESC;

	--	SELECT @TotalCost = SUM(Cost)
	--	FROM #CurrentSquad;

	--	SELECT @Overspend = @TotalCost - 1000;


	--	SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
	--	FROM #CurrentSquad cs;

	--	SELECT ph.PlayerKey,
	--	pa.PlayerPositionKey,
	--	SUM(ph.TotalPoints) AS TotalPoints
	--	FROM dbo.FactPlayerHistory ph
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON ph.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	WHERE ph.SeasonKey = @SeasonKey
	--	AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	--	AND ph.PlayerKey <> @SpecifiedPlayerKey
	--	AND ph.PlayerKey <> @PlayerToRemoveKey
	--	GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	--	HAVING SUM(ph.TotalPoints) > 0
	--	ORDER BY pa.PlayerPositionKey, ph.PlayerKey;

	--	;WITH CurrentTeam AS
	--	(
	--		SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
	--		FROM #CurrentSquad cs
	--	)
	--	,PlayerPointsSummed AS
	--	(
	--		SELECT ph.PlayerKey,
	--		pa.PlayerPositionKey,
	--		SUM(ph.TotalPoints) AS TotalPoints
	--		FROM dbo.FactPlayerHistory ph
	--		INNER JOIN dbo.DimPlayerAttribute pa
	--		ON ph.PlayerKey = pa.PlayerKey
	--		AND pa.SeasonKey = @SeasonKey
	--		WHERE ph.SeasonKey = @SeasonKey
	--		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	--		AND ph.PlayerKey <> @SpecifiedPlayerKey
	--		AND ph.PlayerKey <> @PlayerToRemoveKey
	--		GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	--		HAVING SUM(ph.TotalPoints) > 0
	--	)
	--	--PlayersRanked AS
	--	--(
	--	SELECT ct.PlayerKey AS CurrentPlayerKey,
	--	cp.PlayerName AS CurrentPlayerName,
	--	p.PlayerKey AS NewPlayerKey,
	--	p.PlayerName AS NewPlayerName,  
	--	pa.PlayerPositionKey,
	--	pp.PlayerPositionShort,
	--	ct.Cost AS CurrentPlayerCost,
	--	pgs.Cost AS NewPlayerCost,
	--	ct.TotalPoints AS CurrentPlayerTotalPoints,
	--	pps.TotalPoints AS NewPlayerTotalPoints,
	--	(ct.TotalPoints - pps.TotalPoints) AS DiffPoints,
	--	(pgs.Cost - ct.Cost) AS DiffCost,
	--	--ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
	--	ROW_NUMBER() OVER (ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank,
	--	ct.Cost - @Overspend AS NewPlayerMaxCost
	--	FROM PlayerPointsSummed pps
	--	INNER JOIN dbo.FactPlayerGameweekStatus pgs
	--	ON pps.PlayerKey = pgs.PlayerKey
	--	AND pgs.SeasonKey = @SeasonKey
	--	AND pgs.GameweekKey = @GameweekEnd
	--	INNER JOIN dbo.DimPlayer p
	--	ON pps.PlayerKey = p.PlayerKey
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON pps.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	INNER JOIN dbo.DimPlayerPosition pp
	--	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	--	INNER JOIN CurrentTeam ct
	--	ON pps.PlayerPositionKey = ct.PlayerPositionKey
	--	AND ct.PlayerKey <> @SpecifiedPlayerKey
	--	AND ct.PlayerKey <> @PlayerToRemoveKey
	--	INNER JOIN dbo.DimPlayer cp
	--	ON ct.PlayerKey = cp.PlayerKey
	--	WHERE pgs.Cost < ct.Cost - @Overspend
	--	AND pps.TotalPoints >= ct.TotalPoints - 10
	--	AND NOT EXISTS
	--	(
	--		SELECT 1
	--		FROM #CurrentSquad
	--		WHERE PlayerKey = pps.PlayerKey
	--	);


	--	;WITH CurrentTeam AS
	--	(
	--		SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
	--		FROM #CurrentSquad cs
	--	)
	--	,PlayerPointsSummed AS
	--	(
	--		SELECT ph.PlayerKey,
	--		pa.PlayerPositionKey,
	--		SUM(ph.TotalPoints) AS TotalPoints
	--		FROM dbo.FactPlayerHistory ph
	--		INNER JOIN dbo.DimPlayerAttribute pa
	--		ON ph.PlayerKey = pa.PlayerKey
	--		AND pa.SeasonKey = @SeasonKey
	--		WHERE ph.SeasonKey = @SeasonKey
	--		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	--		AND ph.PlayerKey <> @SpecifiedPlayerKey
	--		AND ph.PlayerKey <> @PlayerToRemoveKey
	--		GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	--		HAVING SUM(ph.TotalPoints) > 0
	--	),
	--	PlayersRanked AS
	--	(
	--		SELECT ct.PlayerKey AS CurrentPlayerKey,
	--		cp.PlayerName AS CurrentPlayerName,
	--		p.PlayerKey AS NewPlayerKey,
	--		p.PlayerName AS NewPlayerName,  
	--		pa.PlayerPositionKey,
	--		pp.PlayerPositionShort,
	--		ct.Cost AS CurrentPlayerCost,
	--		pgs.Cost AS NewPlayerCost,
	--		ct.TotalPoints AS CurrentPlayerTotalPoints,
	--		pps.TotalPoints AS NewPlayerTotalPoints,
	--		(ct.TotalPoints - pps.TotalPoints) AS DiffPoints,
	--		(pgs.Cost - ct.Cost) AS DiffCost,
	--		--ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
	--		ROW_NUMBER() OVER (ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
	--		FROM PlayerPointsSummed pps
	--		INNER JOIN dbo.FactPlayerGameweekStatus pgs
	--		ON pps.PlayerKey = pgs.PlayerKey
	--		AND pgs.SeasonKey = @SeasonKey
	--		AND pgs.GameweekKey = @GameweekEnd
	--		INNER JOIN dbo.DimPlayer p
	--		ON pps.PlayerKey = p.PlayerKey
	--		INNER JOIN dbo.DimPlayerAttribute pa
	--		ON pps.PlayerKey = pa.PlayerKey
	--		AND pa.SeasonKey = @SeasonKey
	--		INNER JOIN dbo.DimPlayerPosition pp
	--		ON pa.PlayerPositionKey = pp.PlayerPositionKey
	--		INNER JOIN CurrentTeam ct
	--		ON pps.PlayerPositionKey = ct.PlayerPositionKey
	--		AND ct.PlayerKey <> @SpecifiedPlayerKey
	--		AND ct.PlayerKey <> @PlayerToRemoveKey
	--		INNER JOIN dbo.DimPlayer cp
	--		ON ct.PlayerKey = cp.PlayerKey
	--		WHERE pgs.Cost < ct.Cost - @Overspend
	--		AND pps.TotalPoints >= ct.TotalPoints - 10
	--		AND NOT EXISTS
	--		(
	--			SELECT 1
	--			FROM #CurrentSquad
	--			WHERE PlayerKey = pps.PlayerKey
	--		)
	--	)
	--	--NewPotentialPlayerRankedByTotalPoints AS
	--	--(
	--	SELECT NewPlayerKey, 
	--	NewPlayerName,
	--	NewPlayerCost,
	--	CurrentPlayerKey,
	--	CurrentPlayerName,
	--	CurrentPlayerCost,
	--	CurrentPlayerTotalPoints,
	--	NewPlayerTotalPoints,
	--	ROW_NUMBER() OVER (ORDER BY DiffPoints, NewPlayerKey) AS TotalPointsRank
	--	FROM PlayersRanked pr
	--	WHERE NOT EXISTS
	--	(
	--		SELECT 1
	--		FROM #CurrentSquad
	--		WHERE PlayerKey = pr.NewPlayerKey
	--		--AND PlayerKey NOT IN (@PlayersToChangeKeys)
	--		AND NOT EXISTS
	--		(
	--			SELECT 1
	--			FROM @PlayersToChangeTable
	--			WHERE PlayerKey = pr.NewPlayerKey 
	--		)
	--	);

	--END
		
	----Get player to move out and player to move into the squad based on cost and points
	--;WITH CurrentTeam AS
	--(
	--	SELECT PlayerKey, PlayerPositionKey, Cost, TotalPoints
	--	FROM #CurrentSquad cs
	--)
	--,PlayerPointsSummed AS
	--(
	--		SELECT ph.PlayerKey,
	--		pa.PlayerPositionKey,
	--		SUM(ph.TotalPoints) AS TotalPoints
	--		FROM dbo.FactPlayerHistory ph
	--		INNER JOIN dbo.DimPlayerAttribute pa
	--		ON ph.PlayerKey = pa.PlayerKey
	--		AND pa.SeasonKey = @SeasonKey
	--		WHERE ph.SeasonKey = @SeasonKey
	--		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	--		AND ph.PlayerKey <> @SpecifiedPlayerKey
	--		AND ph.PlayerKey <> @PlayerToRemoveKey
	--		GROUP BY ph.PlayerKey, pa.PlayerPositionKey
	--		HAVING SUM(ph.TotalPoints) > 0
	--),
	--PlayersRanked AS
	--(
	--	SELECT ct.PlayerKey AS CurrentPlayerKey,
	--	cp.PlayerName AS CurrentPlayerName,
	--	p.PlayerKey AS NewPlayerKey,
	--	p.PlayerName AS NewPlayerName,  
	--	pa.PlayerPositionKey,
	--	pp.PlayerPositionShort,
	--	ct.Cost AS CurrentPlayerCost,
	--	pgs.Cost AS NewPlayerCost,
	--	ct.TotalPoints AS CurrentPlayerTotalPoints,
	--	pps.TotalPoints AS NewPlayerTotalPoints,
	--	(ct.TotalPoints - pps.TotalPoints) AS DiffPoints,
	--	(pgs.Cost - ct.Cost) AS DiffCost,
	--	--ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
	--	ROW_NUMBER() OVER (ORDER BY ct.TotalPoints - pps.TotalPoints) AS PlayerRank
	--	FROM PlayerPointsSummed pps
	--	INNER JOIN dbo.FactPlayerGameweekStatus pgs
	--	ON pps.PlayerKey = pgs.PlayerKey
	--	AND pgs.SeasonKey = @SeasonKey
	--	AND pgs.GameweekKey = @GameweekEnd
	--	INNER JOIN dbo.DimPlayer p
	--	ON pps.PlayerKey = p.PlayerKey
	--	INNER JOIN dbo.DimPlayerAttribute pa
	--	ON pps.PlayerKey = pa.PlayerKey
	--	AND pa.SeasonKey = @SeasonKey
	--	INNER JOIN dbo.DimPlayerPosition pp
	--	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	--	INNER JOIN CurrentTeam ct
	--	ON pps.PlayerPositionKey = ct.PlayerPositionKey
	--	AND ct.PlayerKey <> @SpecifiedPlayerKey
	--	AND ct.PlayerKey <> @PlayerToRemoveKey
	--	--AND ct.PlayerKey NOT IN (@PlayersToChangeKeys)
	--	INNER JOIN dbo.DimPlayer cp
	--	ON ct.PlayerKey = cp.PlayerKey
	--	WHERE pgs.Cost < ct.Cost - @Overspend
	--	AND pps.TotalPoints >= ct.TotalPoints - 10
	--	AND NOT EXISTS
	--	(
	--		SELECT 1
	--		FROM #CurrentSquad
	--		WHERE PlayerKey = pps.PlayerKey
	--	)
	--	AND NOT EXISTS
	--	(
	--		SELECT 1
	--		FROM @PlayersToChangeTable
	--		WHERE PlayerKey = p.PlayerKey 
	--	)
	--),
	--NewPotentialPlayerRankedByTotalPoints AS
	--(
	--	SELECT NewPlayerKey, 
	--	NewPlayerName,
	--	NewPlayerCost,
	--	CurrentPlayerKey,
	--	CurrentPlayerName,
	--	CurrentPlayerCost,
	--	CurrentPlayerTotalPoints,
	--	NewPlayerTotalPoints,
	--	ROW_NUMBER() OVER (ORDER BY DiffPoints, NewPlayerKey) AS TotalPointsRank
	--	FROM PlayersRanked pr
	--	WHERE NOT EXISTS
	--	(
	--		SELECT 1
	--		FROM #CurrentSquad
	--		WHERE PlayerKey = pr.NewPlayerKey
	--		--AND PlayerKey NOT IN (@PlayersToChangeKeys)
	--	)
	--	AND NOT EXISTS
	--	(
	--		SELECT 1
	--		FROM @PlayersToChangeTable
	--		WHERE PlayerKey = pr.NewPlayerKey 
	--	)
	--)
	--SELECT @PlayerKeyToChange = CurrentPlayerKey, 
	--@PlayerToChangeCost = CurrentPlayerCost, 
	--@PlayerKeyToAdd = NewPlayerKey, 
	--@PlayerToAddCost = NewPlayerCost, 
	--@PlayerToAddPoints = NewPlayerTotalPoints,
	--@PlayerToAddName = NewPlayerName,
	--@PlayerToChangeName = CurrentPlayerName
	--FROM NewPotentialPlayerRankedByTotalPoints
	--WHERE TotalPointsRank = 1;

	--IF @Debug=1
	--BEGIN

	--	SELECT @PlayerKeyToChange AS PlayerKeyToChange, 
	--	@PlayerToChangeName AS PlayerToChangeName,
	--	@PlayerToChangeCost AS PlayerToChangeCost, 
	--	@PlayerKeyToAdd AS PlayerKeyToAdd, 
	--	@PlayerToAddName AS PlayerToAddName,
	--	@PlayerToAddCost AS PlayerToAddCost;

	--	SELECT 'SpecifiedPlayerTransferIn End';

	--END

	----Update Old player with new player in temp table
	--UPDATE #CurrentSquad
	--SET PlayerKey = @PlayerKeyToAdd,
	--Cost = @PlayerToAddCost,
	--TotalPoints = @PlayerToAddPoints
	--WHERE PlayerKey = @PlayerKeyToChange;

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='SpecifiedPlayerTransferIn Ending', @Time=@time OUTPUT;
	END

END