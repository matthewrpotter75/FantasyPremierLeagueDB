CREATE PROCEDURE dbo.GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeks
(
	@SeasonKey INT,
	@GameweekKey INT,
	@MinutesLimit INT,
	@MaxCost INT = 1000,
	@PlayerKey INT = NULL,
	@PlayerPosition VARCHAR(3) = NULL,
	@TeamShortName VARCHAR(3) = NULL,
	@Debug BIT = 0
)
AS
BEGIN
	--Calculate points per game for each player by difficulty of opposition for previous number of gameweeks specified
	;WITH Gameweeks AS
	(
		SELECT SeasonKey,
		GameweekKey,
		ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
		FROM dbo.DimGameweek
		WHERE
		(
			(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
			OR
			SeasonKey < @SeasonKey
		)
	),
	fnGetPlayerHistoryRankedByGameweek AS
	(
		SELECT ph.PlayerKey,
		gw.SeasonKey,
		gw.GameweekKey,
		gw.GameweekInc,
		ISNULL(ph.TotalPoints,0) AS TotalPoints,
		ISNULL(ph.[Minutes],0) AS [Minutes],
		ph.WasHome,
		ph.OpponentTeamKey
		FROM Gameweeks gw
		LEFT JOIN dbo.FactPlayerHistory ph
		ON gw.SeasonKey = ph.SeasonKey
		AND gw.GameweekKey = ph.GameweekKey
		WHERE ISNULL(ph.[Minutes],@MinutesLimit + 1) > @MinutesLimit
		AND 
		(
			(gw.SeasonKey = @SeasonKey AND gw.GameweekKey < @GameweekKey)
			OR
			gw.SeasonKey < @SeasonKey
		)
		AND
		(
			ph.PlayerKey = @PlayerKey
			OR
			@PlayerKey IS NULL
		)
	),
	PPGSeason AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPGSeason
		FROM fnGetPlayerHistoryRankedByGameweek ph
		WHERE SeasonKey = @SeasonKey
		GROUP BY ph.PlayerKey
	),
	PPG5 AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG5
		FROM fnGetPlayerHistoryRankedByGameweek ph
		WHERE ph.GameweekInc <= 5
		GROUP BY ph.PlayerKey
	),
	PPG10 AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG10
		FROM fnGetPlayerHistoryRankedByGameweek ph
		WHERE ph.GameweekInc <= 10
		GROUP BY ph.PlayerKey
	),
	PPGAll AS
	(
		SELECT ph.PlayerKey,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPGAll
		FROM fnGetPlayerHistoryRankedByGameweek ph
		GROUP BY ph.PlayerKey
	)
	SELECT 
	p.PlayerKey,
	p.PlayerName,
	p.WebName,
	t.TeamShortName,
	pp.PlayerPositionShort AS PlayerPosition,
	CAST((fpcs.Cost * 1.0)/10  AS DECIMAL(5,1)) AS Cost,
	PPG5.PPG5 - PPG10.PPG10 AS PPGImprovement5Games,
	PPG5.PPG5 - PPGS.PPGSeason AS PPGImprovementSeason,
	PPG5.Points AS PPG5Points,
	PPG5.Games AS PPG5Games,
	PPG5.PPG5,
	PPG10.Points AS PPG10Points,
	PPG10.Games AS PPG10Games,
	PPG10.PPG10,
	PPGS.Points AS PPGSeasonPoints,
	PPGS.Games AS PPGSeasonGames,
	PPGS.PPGSeason,
	PPGAll.Points AS PPGAllPoints,
	PPGAll.Games AS PPGAllGames,
	PPGAll.PPGAll
	FROM PPGAll
	INNER JOIN
	PPGSeason PPGS
	ON PPGAll.PlayerKey = PPGS.PlayerKey
	INNER JOIN PPG10
	ON PPGAll.PlayerKey = PPG10.PlayerKey
	INNER JOIN PPG5
	ON PPGAll.PlayerKey = PPG5.PlayerKey
	INNER JOIN dbo.DimPlayer p
	ON PPG5.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
	INNER JOIN dbo.FactPlayerCurrentStats fpcs
	ON p.PlayerKey = fpcs.PlayerKey
	WHERE (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
	AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
	AND fpcs.Cost <= @MaxCost
	ORDER BY PPG5.Points DESC;
	
	IF @Debug = 1
	BEGIN

		SELECT 'Gameweeks';

		SELECT SeasonKey,
		GameweekKey,
		ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
		FROM dbo.DimGameweek
		WHERE
		(
			(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
			OR
			SeasonKey < @SeasonKey
		);

		SELECT 'fnGetPlayerHistoryRankedByGameweek';

		;WITH Gameweeks AS
		(
			SELECT SeasonKey,
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
			FROM dbo.DimGameweek
			WHERE
			(
				(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
				OR
				SeasonKey < @SeasonKey
			)
		)
		SELECT ph.PlayerKey,
		gw.SeasonKey,
		gw.GameweekKey,
		gw.GameweekInc,
		ISNULL(ph.TotalPoints,0) AS TotalPoints,
		ISNULL(ph.[Minutes],0) AS [Minutes],
		ph.WasHome,
		ph.OpponentTeamKey
		FROM Gameweeks gw
		LEFT JOIN dbo.FactPlayerHistory ph
		ON gw.SeasonKey = ph.SeasonKey
		AND gw.GameweekKey = ph.GameweekKey
		WHERE ISNULL(ph.[Minutes],@MinutesLimit + 1) > @MinutesLimit
		AND 
		(
			(gw.SeasonKey = @SeasonKey AND gw.GameweekKey < @GameweekKey)
			OR
			gw.SeasonKey < @SeasonKey
		)
		AND
		(
			ph.PlayerKey = @PlayerKey
			OR
			@PlayerKey IS NULL
		)

		SELECT 'PPGSeason';

		;WITH Gameweeks AS
		(
			SELECT SeasonKey,
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
			FROM dbo.DimGameweek
			WHERE
			(
				(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
				OR
				SeasonKey < @SeasonKey
			)
		),		
		fnGetPlayerHistoryRankedByGameweek AS
		(
			SELECT ph.PlayerKey,
			gw.SeasonKey,
			gw.GameweekKey,
			gw.GameweekInc,
			ISNULL(ph.TotalPoints,0) AS TotalPoints,
			ISNULL(ph.[Minutes],0) AS [Minutes],
			ph.WasHome,
			ph.OpponentTeamKey
			FROM Gameweeks gw
			LEFT JOIN dbo.FactPlayerHistory ph
			ON gw.SeasonKey = ph.SeasonKey
			AND gw.GameweekKey = ph.GameweekKey
			WHERE ISNULL(ph.[Minutes],@MinutesLimit + 1) > @MinutesLimit
			AND 
			(
				(gw.SeasonKey = @SeasonKey AND gw.GameweekKey < @GameweekKey)
				OR
				gw.SeasonKey < @SeasonKey
			)
			AND
			(
				ph.PlayerKey = @PlayerKey
				OR
				@PlayerKey IS NULL
			)
		)
		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort AS PlayerPosition,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPGSeason
		FROM fnGetPlayerHistoryRankedByGameweek ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		WHERE ph.SeasonKey = @SeasonKey
		AND (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
		AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort
		ORDER BY Points DESC;

		SELECT 'PPG5';

		;WITH Gameweeks AS
		(
			SELECT SeasonKey,
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
			FROM dbo.DimGameweek
			WHERE
			(
				(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
				OR
				SeasonKey < @SeasonKey
			)
		),		
		fnGetPlayerHistoryRankedByGameweek AS
		(
			SELECT ph.PlayerKey,
			gw.SeasonKey,
			gw.GameweekKey,
			gw.GameweekInc,
			ISNULL(ph.TotalPoints,0) AS TotalPoints,
			ISNULL(ph.[Minutes],0) AS [Minutes],
			ph.WasHome,
			ph.OpponentTeamKey
			FROM Gameweeks gw
			LEFT JOIN dbo.FactPlayerHistory ph
			ON gw.SeasonKey = ph.SeasonKey
			AND gw.GameweekKey = ph.GameweekKey
			WHERE ISNULL(ph.[Minutes],@MinutesLimit + 1) > @MinutesLimit
			AND 
			(
				(gw.SeasonKey = @SeasonKey AND gw.GameweekKey < @GameweekKey)
				OR
				gw.SeasonKey < @SeasonKey
			)
			AND
			(
				ph.PlayerKey = @PlayerKey
				OR
				@PlayerKey IS NULL
			)
		)
		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort AS PlayerPosition,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG5
		FROM fnGetPlayerHistoryRankedByGameweek ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		WHERE ph.GameweekInc <= 5
		AND (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
		AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort
		ORDER BY Points DESC;

		SELECT 'PPG10';

		;WITH Gameweeks AS
		(
			SELECT SeasonKey,
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
			FROM dbo.DimGameweek
			WHERE
			(
				(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
				OR
				SeasonKey < @SeasonKey
			)
		),		
		fnGetPlayerHistoryRankedByGameweek AS
		(
			SELECT ph.PlayerKey,
			gw.SeasonKey,
			gw.GameweekKey,
			gw.GameweekInc,
			ISNULL(ph.TotalPoints,0) AS TotalPoints,
			ISNULL(ph.[Minutes],0) AS [Minutes],
			ph.WasHome,
			ph.OpponentTeamKey
			FROM Gameweeks gw
			LEFT JOIN dbo.FactPlayerHistory ph
			ON gw.SeasonKey = ph.SeasonKey
			AND gw.GameweekKey = ph.GameweekKey
			WHERE ISNULL(ph.[Minutes],@MinutesLimit + 1) > @MinutesLimit
			AND 
			(
				(gw.SeasonKey = @SeasonKey AND gw.GameweekKey < @GameweekKey)
				OR
				gw.SeasonKey < @SeasonKey
			)
			AND
			(
				ph.PlayerKey = @PlayerKey
				OR
				@PlayerKey IS NULL
			)
		)
		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort AS PlayerPosition,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPG10
		FROM fnGetPlayerHistoryRankedByGameweek ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		WHERE ph.GameweekInc <= 10
		AND (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
		AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort
		ORDER BY Points DESC;

		SELECT 'PPGAll';

		;WITH Gameweeks AS
		(
			SELECT SeasonKey,
			GameweekKey,
			ROW_NUMBER() OVER (ORDER BY SeasonKey DESC, GameweekKey DESC) AS GameweekInc
			FROM dbo.DimGameweek
			WHERE
			(
				(SeasonKey = @SeasonKey AND GameweekKey < @GameweekKey)
				OR
				SeasonKey < @SeasonKey
			)
		),		
		fnGetPlayerHistoryRankedByGameweek AS
		(
			SELECT ph.PlayerKey,
			gw.SeasonKey,
			gw.GameweekKey,
			gw.GameweekInc,
			ISNULL(ph.TotalPoints,0) AS TotalPoints,
			ISNULL(ph.[Minutes],0) AS [Minutes],
			ph.WasHome,
			ph.OpponentTeamKey
			FROM Gameweeks gw
			LEFT JOIN dbo.FactPlayerHistory ph
			ON gw.SeasonKey = ph.SeasonKey
			AND gw.GameweekKey = ph.GameweekKey
			WHERE ISNULL(ph.[Minutes],@MinutesLimit + 1) > @MinutesLimit
			AND 
			(
				(gw.SeasonKey = @SeasonKey AND gw.GameweekKey < @GameweekKey)
				OR
				gw.SeasonKey < @SeasonKey
			)
			AND
			(
				ph.PlayerKey = @PlayerKey
				OR
				@PlayerKey IS NULL
			)
		)
		SELECT ph.PlayerKey,
		p.PlayerName,
		pp.PlayerPositionShort AS PlayerPosition,
		SUM(ph.TotalPoints) AS Points,
		COUNT(ph.PlayerKey) AS Games,
		SUM(ph.[Minutes]) AS PlayerMinutes,
		CASE WHEN COUNT(ph.GameweekKey) <> 0 THEN SUM(CAST(ph.TotalPoints AS DECIMAL(8,6)))/COUNT(ph.GameweekKey) ELSE 0 END AS PPGAll
		FROM fnGetPlayerHistoryRankedByGameweek ph
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		WHERE (@PlayerPosition IS NULL OR pp.PlayerPositionShort = @PlayerPosition)
		AND (@TeamShortName IS NULL OR t.TeamShortName = @TeamShortName)
		GROUP BY ph.PlayerKey, p.PlayerName, pp.PlayerPositionShort
		ORDER BY Points DESC;

	END

END