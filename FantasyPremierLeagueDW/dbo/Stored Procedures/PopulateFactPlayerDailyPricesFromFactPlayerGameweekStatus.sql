CREATE PROCEDURE dbo.PopulateFactPlayerDailyPricesFromFactPlayerGameweekStatus
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO dbo.FactPlayerDailyPrices
	([PlayerKey],[TeamKey],[DateKey],[Cost])
	SELECT pgs.PlayerKey,
	pgs.TeamKey,
	d.DateKey,
	pgs.Cost
	--gw.SeasonKey,
	--gw.GameweekKey
	FROM dbo.FactPlayerGameweekStatus pgs
	INNER JOIN dbo.DimGameweek gw
	ON pgs.SeasonKey = gw.SeasonKey
	AND pgs.GameweekKey = gw.GameweekKey
	INNER JOIN dbo.DimDate d
	ON CAST(DATEADD(day,3,gw.DeadlineTime) AS DATE) = d.[Date]
	--ON CAST(gw.DeadlineTime AS DATE) = d.[Date]
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.FactPlayerDailyPrices
		WHERE PlayerKey = pgs.PlayerKey
		AND TeamKey = pgs.TeamKey
		AND DateKey = d.DateKey
	)
	ORDER BY DateKey,PlayerKey;

END