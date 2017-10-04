CREATE FUNCTION dbo.fnGetPlayersRanked
(
	@SeasonKey INT = NULL,
	@SpecifiedPlayerKey INT = NULL,
	@PlayerToRemoveKey INT = NULL,
	@PlayersToChangeKeys VARCHAR(100) = '',
	@MaxNumberOfTransfers INT = 1,	
	@GameweekStart INT,
	@GameweekEnd INT,
	@TotalPointsRange INT = 10,
	@PlayersToChangeTable UDTPlayersToChangeTable READONLY
)
RETURNS 
@PlayersRanked TABLE 
(
	Id INT,
	CurrentPlayerKey INT,
	CurrentPlayerName INT,
	NewPlayerKey INT,
	NewPlayerName INT,  
	PlayerPositionKey INT,
	PlayerPositionShort INT,
	CurrentPlayerCost INT,
	NewPlayerCost INT,
	CurrentPlayerTotalPoints INT,
	NewPlayerTotalPoints INT,
	DiffPoints INT,
	DiffCost INT,
	PlayerRank INT
)
AS
BEGIN

	--Get player to move out and player to move into the squad based on cost and points
	;WITH CurrentTeam AS
	(
		SELECT my.*, pa.PlayerPositionKey, pa.TeamKey, pcs.TotalPoints,
		ROW_NUMBER() OVER (ORDER BY pa.PlayerPositionKey, my.PlayerKey) AS Id
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayerAttribute pa
		ON my.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON my.PlayerKey = pcs.PlayerKey
		WHERE my.SeasonKey = @SeasonKey
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
	)
	INSERT INTO @PlayersRanked
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
	);

	RETURN 
END