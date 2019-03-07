CREATE PROCEDURE dbo.GetAllPlayerPPGForHomeAgainstAwayMatches
(
	@SeasonKey INT = NULL,
	@PlayerKey INT = NULL,
	@PlayerPosition VARCHAR(3) = NULL,
	@TeamShortName VARCHAR(3) = NULL,
	@MinGames INT = 5,
	@MinutesLimit INT = 60,
	@MaxCost INT = 1000,
	@Debug BIT = 0
)
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SeasonKeyPA INT;

	IF @SeasonKey IS NULL
		SELECT @SeasonKeyPA = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	ELSE
		SELECT @SeasonKeyPA = @SeasonKey;

	;WITH PlayerHistory AS
	(
		SELECT ph.PlayerHistoryKey,
		ph.PlayerKey,
		gw.SeasonKey,
		gw.GameweekKey,
		ph.WasHome,
		ISNULL(ph.TotalPoints,0) AS TotalPoints,
		ISNULL(ph.[Minutes],0) AS [Minutes],
		ph.OpponentTeamKey
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON ph.PlayerKey = pcs.PlayerKey
		LEFT JOIN dbo.DimGameweek gw
		ON gw.SeasonKey = ph.SeasonKey
		AND gw.GameweekKey = ph.GameweekKey
		WHERE ph.[Minutes] >= @MinutesLimit
		AND pcs.Cost <= @MaxCost
		AND
		(
			gw.SeasonKey = @SeasonKey
			OR 
			@SeasonKey IS NULL
		)
		AND
		(
			ph.PlayerKey = @PlayerKey
			OR
			@PlayerKey IS NULL
		)
	),
	PlayerTotalHomeAwayPoints AS
	(
		SELECT PlayerKey, [1] AS TotalHomePoints, [0] AS TotalAwayPoints
		FROM
		(
			SELECT DISTINCT PlayerKey, WasHome, TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			SUM(TotalPoints)
			FOR WasHome IN ([0],[1])
		) piv
	),
	PlayerTotalHomeAwayGames AS
	(
		SELECT PlayerKey, [1] AS TotalHomeGames, [0] AS TotalAwayGames
		FROM
		(
			SELECT DISTINCT PlayerKey, WasHome, TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			COUNT(TotalPoints)
			FOR WasHome IN ([0],[1])
		) piv
	),
	PlayerAvgHomeAwayPoints AS
	(
		SELECT PlayerKey, [1] AS AvgHomePoints,[0] AS AvgAwayPoints
		FROM
		(
			SELECT DISTINCT PlayerKey, WasHome, TotalPoints * 1.0 AS TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			AVG(TotalPoints)
			FOR WasHome IN ([0],[1])
		) piv
	)
	SELECT p.PlayerName,
	pp.PlayerPositionShort AS PlayerPosition,
	t.TeamShortName AS TeamName,
	pcs.Cost,
	ap.AvgHomePoints,
	ap.AvgAwayPoints,
	(ap.AvgHomePoints - ap.AvgAwayPoints) AS DiffHomeAway,
	tp.TotalHomePoints, 
	tg.TotalHomeGames, 
	tp.TotalAwayPoints, 
	tg.TotalAwayGames
	FROM dbo.DimPlayer p
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKeyPA
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON p.PlayerKey = pcs.PlayerKey
	INNER JOIN PlayerTotalHomeAwayPoints tp
	ON p.PlayerKey = tp.PlayerKey
	INNER JOIN PlayerTotalHomeAwayGames tg
	ON tp.PlayerKey = tg.PlayerKey
	INNER JOIN PlayerAvgHomeAwayPoints ap
	ON tp.PlayerKey = ap.PlayerKey
	WHERE (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
	AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
	AND pcs.Cost <= @MaxCost
	AND tg.TotalHomeGames >= @MinGames
	AND tg.TotalAwayGames >= @MinGames
	ORDER BY DiffHomeAway DESC;

END