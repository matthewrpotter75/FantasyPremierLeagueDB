CREATE PROCEDURE dbo.GetAllPlayerPPGForSeasonHalfAndSeasonPart
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
		gw.SeasonPart,
		gw.SeasonHalf,
		ISNULL(ph.TotalPoints,0) AS TotalPoints,
		ISNULL(ph.[Minutes],0) AS [Minutes],
		ph.WasHome,
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
	PlayerSeasonPartTotalPoints AS
	(
		SELECT PlayerKey, [1] AS TotalPointsSP1,[2] AS TotalPointsSP2,[3] AS TotalPointsSP3,[4] AS TotalPointsSP4
		FROM
		(
			SELECT DISTINCT PlayerKey, SeasonPart, TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			SUM(TotalPoints)
			FOR SeasonPart IN ([1],[2],[3],[4])
		) piv
	),
	PlayerSeasonPartTotalGames AS
	(
		SELECT PlayerKey, [1] AS TotalGamesSP1,[2] AS TotalGamesSP2,[3] AS TotalGamesSP3,[4] AS TotalGamesSP4
		FROM
		(
			SELECT DISTINCT PlayerKey, SeasonPart, TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			COUNT(TotalPoints)
			FOR SeasonPart IN ([1],[2],[3],[4])
		) piv
	),
	PlayerSeasonPartAvgPoints AS
	(
		SELECT PlayerKey, [1] AS AvgPointsSP1,[2] AS AvgPointsSP2,[3] AS AvgPointsSP3,[4] AS AvgPointsSP4
		FROM
		(
			SELECT DISTINCT PlayerKey, SeasonPart, TotalPoints * 1.0 AS TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			AVG(TotalPoints)
			FOR SeasonPart IN ([1],[2],[3],[4])
		) piv
	),
	PlayerSeasonHalfTotalPoints AS
	(
		SELECT PlayerKey, [1] AS TotalPointsSH1,[2] AS TotalPointsSH2
		FROM
		(
			SELECT DISTINCT PlayerKey, SeasonHalf, TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			SUM(TotalPoints)
			FOR SeasonHalf IN ([1],[2])
		) piv
	),
	PlayerSeasonHalfTotalGames AS
	(
		SELECT PlayerKey, [1] AS TotalGamesSH1,[2] AS TotalGamesSH2
		FROM
		(
			SELECT DISTINCT PlayerKey, SeasonHalf, TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			COUNT(TotalPoints)
			FOR SeasonHalf IN ([1],[2])
		) piv
	),
	PlayerSeasonHalfAvgPoints AS
	(
		SELECT PlayerKey, [1] AS AvgPointsSH1,[2] AS AvgPointsSH2
		FROM
		(
			SELECT DISTINCT PlayerKey, SeasonHalf, TotalPoints * 1.0 AS TotalPoints
			FROM PlayerHistory ph
		) src
		PIVOT
		(
			AVG(TotalPoints)
			FOR SeasonHalf IN ([1],[2])
		) piv
	)
	SELECT p.PlayerName,
	pp.PlayerPositionShort AS PlayerPosition,
	t.TeamShortName AS TeamName,
	pcs.Cost,
	pshap.AvgPointsSH1,
	pshap.AvgPointsSH2,
	(pshap.AvgPointsSH1 - pshap.AvgPointsSH2) AS DiffSeasonHalf,
	pspap.AvgPointsSP1,
	pspap.AvgPointsSP2,
	pspap.AvgPointsSP3,
	pspap.AvgPointsSP4,
	psptp.TotalPointsSP1, psptg.TotalGamesSP1, 
	psptp.TotalPointsSP2, psptg.TotalGamesSP2, 
	psptp.TotalPointsSP3, psptg.TotalGamesSP3, 
	psptp.TotalPointsSP4, psptg.TotalGamesSP4, 
	pshtp.TotalPointsSH1, pshtg.TotalGamesSH1, 
	pshtp.TotalPointsSH2, pshtg.TotalGamesSH2
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
	INNER JOIN PlayerSeasonPartTotalPoints psptp
	ON p.PlayerKey = psptp.PlayerKey
	INNER JOIN PlayerSeasonPartTotalGames psptg
	ON psptp.PlayerKey = psptg.PlayerKey
	INNER JOIN PlayerSeasonPartAvgPoints pspap
	ON psptp.PlayerKey = pspap.PlayerKey
	INNER JOIN PlayerSeasonHalfTotalPoints pshtp
	ON psptp.PlayerKey = pshtp.PlayerKey
	INNER JOIN PlayerSeasonHalfTotalGames pshtg
	ON psptp.PlayerKey = pshtg.PlayerKey
	INNER JOIN PlayerSeasonHalfAvgPoints pshap
	ON psptp.PlayerKey = pshap.PlayerKey
	WHERE (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
	AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
	AND pcs.Cost <= @MaxCost
	AND pshtg.TotalGamesSH1 >= @MinGames
	AND pshtg.TotalGamesSH2 >= @MinGames
	ORDER BY DiffSeasonHalf DESC;

END