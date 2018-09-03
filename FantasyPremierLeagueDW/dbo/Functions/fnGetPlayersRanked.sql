CREATE FUNCTION dbo.fnGetPlayersRanked
(
	@UserTeamKey INT = NULL,
	@SeasonKey INT = NULL,
	@SpecifiedPlayerKey INT = NULL,
	@PlayerToRemoveKey INT = NULL,
	@PlayersToChangeKeys VARCHAR(100) = '',
	@MaxNumberOfTransfers INT = 1,	
	@GameweekStart INT,
	@GameweekEnd INT,
	@TotalPointsRange INT = 10,
	@PlayersToChangeCost INT,
	@Overspend INT,
	@PlayersToChangeTable UDTPlayersToChangeTable READONLY
)
RETURNS 
@PlayersRanked TABLE 
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
)
AS
BEGIN

	--Get player to move out and player to move into the squad based on cost and points
	;WITH CurrentTeam AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY pa.PlayerPositionKey, my.PlayerKey) AS Id,
		my.*, pa.PlayerPositionKey, pa.TeamKey, pcs.TotalPoints
		FROM dbo.DimUserTeamPlayer my
		INNER JOIN dbo.DimPlayerAttribute pa
		ON my.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON my.PlayerKey = pcs.PlayerKey
		WHERE my.UserTeamKey = @UserTeamKey
		AND my.SeasonKey = @SeasonKey
		AND my.GameweekKey = @GameweekEnd
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
			FROM CurrentTeam
			WHERE PlayerKey = pps.PlayerKey
		)
	),
	AnchorPlayer AS
	(
		SELECT p.Id,
		CAST(p.CurrentPlayerKey AS VARCHAR(100)) AS CurrentPlayerKeyPath,
		CAST(p.NewPlayerKey AS VARCHAR(100)) AS NewPlayerKeyPath,
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
		CAST(p.CurrentPlayerCost AS INT) AS CurrentPlayerCostSummed,
		CAST(p.NewPlayerCost AS INT) AS NewPlayerCostSummed,
		p.CurrentPlayerTotalPoints AS CurrentPlayerPointsSummed,
		p.NewPlayerTotalPoints AS NewPlayerPointsSummed,
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
		CAST(ap.CurrentPlayerKeyPath + ',' + CAST(p.CurrentPlayerKey AS VARCHAR(100)) AS VARCHAR(100)) AS CurrentPlayerKeyPath,
		CAST(ap.NewPlayerKeyPath + ',' + CAST(p.NewPlayerKey AS VARCHAR(100)) AS VARCHAR(100)) AS NewPlayerKeyPath,
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
		(CAST(p.CurrentPlayerCost AS INT) + ap.CurrentPlayerCostSummed)AS CurrentPlayerCostSummed,
		(CAST(p.NewPlayerCost AS INT) + ap.NewPlayerCostSummed) AS NewPlayerCostSummed,
		(p.CurrentPlayerTotalPoints + ap.CurrentPlayerPointsSummed) AS NewPlayerPointsSummed,
		(p.NewPlayerTotalPoints + ap.NewPlayerPointsSummed) AS PointsSummed,
		(ap.RecursionLevel + 1) AS RecursionLevel
		FROM PlayersRanked p
		INNER JOIN dbo.FactPlayerCurrentStats cpcs
		ON p.CurrentPlayerKey = cpcs.PlayerKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON p.NewPlayerKey = pcs.PlayerKey
		INNER JOIN AnchorPlayer ap
		ON p.Id = (ap.RecursionLevel + 1)
		WHERE p.CurrentPlayerKey <> ap.CurrentPlayerKey
		AND p.NewPlayerKey <> ap.NewPlayerKey
		AND (CAST(pcs.Cost AS INT) + ap.NewPlayerCostSummed) <= ISNULL(@PlayersToChangeCost,cpcs.Cost) - @Overspend
		AND (ap.RecursionLevel + 1) <= @MaxNumberOfTransfers
		AND p.PlayerRank <= 20
	)
	INSERT INTO @PlayersRanked
	(Id, CurrentPlayerKeyPath, NewPlayerKeyPath, RowNum, PlayerPositionKey, CurrentPlayerKey, CurrentPlayerName, CurrentPlayerCost, CurrentPlayerTotalPoints, NewPlayerKey, NewPlayerName, NewPlayerCost, NewPlayerTotalPoints, CurrentPlayerCostSummed, NewPlayerCostSummed, CurrentPlayerPointsSummed, NewPlayerPointsSummed, RecursionLevel, DiffPoints, DiffCost, CombinationRank)
	SELECT Id, 
	CurrentPlayerKeyPath,
	NewPlayerKeyPath,
	RowNum,
	PlayerPositionKey, 
	CurrentPlayerKey, 
	CurrentPlayerName,
	CurrentPlayerCost, 
	CurrentPlayerTotalPoints, 
	NewPlayerKey, 
	NewPlayerName, 
	NewPlayerCost, 
	NewPlayerTotalPoints, 
	CurrentPlayerCostSummed,	
	NewPlayerCostSummed,	
	CurrentPlayerPointsSummed,
	NewPlayerPointsSummed, 
	RecursionLevel,
	(NewPlayerPointsSummed - CurrentPlayerPointsSummed) AS DiffPoints,
	(CurrentPlayerCostSummed - NewPlayerCostSummed) AS DiffCost,
	ROW_NUMBER() OVER (PARTITION BY RecursionLevel, CurrentPlayerKey ORDER BY NewPlayerPointsSummed DESC) AS CombinationRank
	FROM AnchorPlayer;

	RETURN 

END