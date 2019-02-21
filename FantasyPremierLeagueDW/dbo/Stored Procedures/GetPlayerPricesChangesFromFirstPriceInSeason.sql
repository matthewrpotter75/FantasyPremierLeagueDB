CREATE PROCEDURE dbo.GetPlayerPricesChangesFromFirstPriceInSeason
(
	@SeasonKey INT
)
AS
BEGIN

	SET NOCOUNT ON;

	;WITH PlayerDateRankedAsc AS
	(
		SELECT pdp.PlayerKey,
		pdp.DateKey,
		pdp.TeamKey,
		pdp.Cost,
		ROW_NUMBER() OVER (PARTITION BY pdp.PlayerKey ORDER BY pdp.DateKey ASC) AS PlayerDateRowNumber
		FROM dbo.FactPlayerDailyPrices pdp
		INNER JOIN dbo.DimDate d
		ON pdp.DateKey = d.DateKey
		WHERE SeasonKey = @SeasonKey
	),
	PlayerDateRankedDesc AS
	(
		SELECT pdp.PlayerKey,
		pdp.DateKey,
		pdp.TeamKey,
		pdp.Cost,
		ROW_NUMBER() OVER (PARTITION BY pdp.PlayerKey ORDER BY pdp.DateKey DESC) AS PlayerDateRowNumber
		FROM dbo.FactPlayerDailyPrices pdp
		INNER JOIN dbo.DimDate d
		ON pdp.DateKey = d.DateKey
		WHERE SeasonKey = @SeasonKey
	),
	EarliestPlayerCost AS
	(
		SELECT *
		FROM PlayerDateRankedAsc
		WHERE PlayerDateRowNumber = 1
	),
	LatestPlayerCost AS
	(
		SELECT *, CAST(Cost AS SMALLINT) AS CostINT
		FROM PlayerDateRankedDesc
		WHERE PlayerDateRowNumber = 1
	)
	SELECT lpc.PlayerKey,
	p.PlayerName, 
	t.TeamShortName AS Team,		
	pp.PlayerPositionShort AS PlayerPosition,
	ed.DisplayDate AS FirstDate,
	ld.DisplayDate AS LatestDate,
	epc.Cost AS FirstCost,
	lpc.Cost AS LatestCost,
	lpc.CostINT - epc.Cost AS CostChange,
	CASE
		WHEN lpc.Cost > epc.Cost THEN 'INC'
		ELSE 'DEC'
	END AS ChangeDirection
	FROM EarliestPlayerCost epc
	INNER JOIN LatestPlayerCost lpc
	ON epc.PlayerKey = lpc.PlayerKey
	INNER JOIN dbo.DimPlayer p
	ON lpc.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimDate ed
	ON lpc.DateKey = ed.DateKey
	INNER JOIN dbo.DimDate ld
	ON lpc.DateKey = ld.DateKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = ld.SeasonKey
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	ORDER BY CostChange DESC;

END