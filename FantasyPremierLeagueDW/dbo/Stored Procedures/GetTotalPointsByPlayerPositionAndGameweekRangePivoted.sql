CREATE PROCEDURE dbo.GetTotalPointsByPlayerPositionAndGameweekRangePivoted
(
	@SeasonKey INT,
	@StartGameweekKey INT = 1,
	@EndGameweekKey INT = NULL,
	@MinMinutesPlayed INT = 30
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @EndGameweekKey IS NULL
	BEGIN
		SELECT @EndGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE() 
	END

	;WITH TeamAvgPoints AS
	(
		SELECT dt.TeamShortName AS TeamName,
		dpp.PlayerPositionKey,
		SUM(fph.TotalPoints) AS TotalPoints,
		COUNT(fph.PlayerHistoryKey) AS TotalGames,
		AVG(fph.TotalPoints * 1.0) AS AvgPoints
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON fph.PlayerKey = dpa.PlayerKey
		AND fph.SeasonKey = dpa.SeasonKey
		INNER JOIN dbo.DimTeam dt
		ON dpa.TeamKey = dt.TeamKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @StartGameweekKey AND @EndGameweekKey
		AND fph.[Minutes] > @MinMinutesPlayed
		GROUP BY dt.TeamShortName, dpp.PlayerPositionKey, dpp.SingularNameShort
	),
	TeamPlayerAvgPoints AS
	(
		SELECT fph.PlayerKey, 
		dt.TeamShortName AS TeamName,
		dpp.PlayerPositionKey,
		SUM(fph.TotalPoints) AS TotalPoints,
		COUNT(fph.PlayerHistoryKey) AS TotalGames,
		AVG(fph.TotalPoints * 1.0) AS AvgPoints
		FROM dbo.FactPlayerHistory fph
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON fph.PlayerKey = dpa.PlayerKey
		AND fph.SeasonKey = dpa.SeasonKey
		INNER JOIN dbo.DimTeam dt
		ON dpa.TeamKey = dt.TeamKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.GameweekKey BETWEEN @StartGameweekKey AND @EndGameweekKey
		AND fph.[Minutes] > @MinMinutesPlayed
		GROUP BY fph.PlayerKey, dt.TeamShortName, dpp.PlayerPositionKey, dpp.SingularNameShort
	),
	AvgPlayerPoints AS
	(
		SELECT TeamName, PlayerKey, [1] AS GKP,[2] AS DEF,[3] AS MID,[4] AS FWD
		FROM 
		(
			SELECT TeamName, PlayerKey, PlayerPositionKey, AvgPoints
			FROM TeamPlayerAvgPoints
		) AvgPlayerPoints
		PIVOT
		(
			MIN(AvgPoints)
			FOR PlayerPositionKey IN ([1],[2],[3],[4])
		) piv
	),
	TeamMinMaxAvgPoints AS
	(
		SELECT TeamName, 
		MIN(GKP) AS MinGKPAvg, 
		MIN(DEF) AS MinDEFAvg, 
		MIN(MID) AS MinMIDAvg, 
		MIN(FWD) AS MinFWDAvg,
		MAX(GKP) AS MaxGKPAvg, 
		MAX(DEF) AS MaxDEFAvg, 
		MAX(MID) AS MaxMIDAvg, 
		MAX(FWD) AS MaxFWDAvg
		FROM AvgPlayerPoints
		GROUP BY TeamName
	),
	AvgPoints AS
	(
		SELECT TeamName, [1] AS GKP,[2] AS DEF,[3] AS MID,[4] AS FWD
		FROM 
		(
			SELECT TeamName, PlayerPositionKey, AvgPoints
			FROM TeamAvgPoints
		) AvgPoints
		PIVOT
		(
			MIN(AvgPoints)
			FOR PlayerPositionKey IN ([1],[2],[3],[4])
		) piv
	),
	TotalPoints AS
	(
		SELECT TeamName, [1] AS GKP,[2] AS DEF,[3] AS MID,[4] AS FWD
		FROM 
		(
			SELECT TeamName, PlayerPositionKey, TotalPoints
			FROM TeamAvgPoints
		) AvgPoints
		PIVOT
		(
			MIN(TotalPoints)
			FOR PlayerPositionKey IN ([1],[2],[3],[4])
		) piv
	),
	TotalGames AS
	(
		SELECT TeamName, [1] AS GKP,[2] AS DEF,[3] AS MID,[4] AS FWD
		FROM 
		(
			SELECT TeamName, PlayerPositionKey, TotalGames
			FROM TeamAvgPoints
		) AvgPoints
		PIVOT
		(
			MIN(TotalGames)
			FOR PlayerPositionKey IN ([1],[2],[3],[4])
		) piv
	)
	SELECT tp.TeamName, 
	tp.GKP AS GKPPoints, 
	tp.DEF AS DEFPoints, 
	tp.MID AS MIDPoints, 
	tp.FWD AS FWDPoints, 
	tg.GKP AS GKPGames, 
	tg.DEF AS DEFGames, 
	tg.MID AS MIDGames, 
	tg.FWD AS FWDGames, 
	ap.GKP AS GKPAvgPoints, 
	ap.DEF AS DEFAvgPoints, 
	ap.MID AS MIDAvgPoints, 
	ap.FWD AS FWDAvgPoints,
	tmmap.MinGKPAvg,
	tmmap.MaxGKPAvg,
	tmmap.MinDEFAvg,
	tmmap.MaxDEFAvg,
	tmmap.MinMIDAvg,
	tmmap.MaxMIDAvg,
	tmmap.MinFWDAvg,
	tmmap.MaxFWDAvg
	FROM TotalPoints tp
	INNER JOIN TotalGames tg
	ON tp.TeamName = tg.TeamName
	INNER JOIN AvgPoints ap
	ON tp.TeamName = ap.TeamName
	INNER JOIN TeamMinMaxAvgPoints tmmap
	ON ap.TeamName = tmmap.TeamName
	ORDER BY TeamName;

END