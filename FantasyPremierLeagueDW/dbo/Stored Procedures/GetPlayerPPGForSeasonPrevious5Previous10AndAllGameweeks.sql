CREATE PROCEDURE dbo.GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeks
(
	@SeasonKey INT,
	@GameweekKey INT,
	@PlayerKey INT,
	@MinutesLimit INT,
	@Debug BIT = 0
)
AS
BEGIN
	--Calculate points per game for each player by difficulty of opposition for previous number of gameweeks specified
	;WITH fnGetPlayerHistoryRankedByGameweek AS
	(
		SELECT ph.PlayerKey,
		ph.SeasonKey,
		ph.GameweekKey,
		ROW_NUMBER() OVER (PARTITION BY ph.PlayerKey ORDER BY ph.SeasonKey DESC, ph.GameweekKey DESC) AS GameweekInc,
		ph.TotalPoints,
		ph.[Minutes],
		ph.WasHome,
		ph.OpponentTeamKey
		FROM dbo.FactPlayerHistory ph
		WHERE ph.PlayerKey = @PlayerKey
		AND ph.[Minutes] > @MinutesLimit
		AND 
		(
			(ph.SeasonKey = @SeasonKey AND ph.GameweekKey < @GameweekKey)
			OR
			ph.SeasonKey < @SeasonKey
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
		WHERE ph.GameweekInc <= 38
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
	SELECT PPGAll.PlayerKey, PPG5.PPG5, PPG10.PPG10, PPGS.PPGSeason, PPGAll.PPGAll
	FROM PPGAll
	INNER JOIN
	PPGSeason PPGS
	ON PPGAll.PlayerKey = PPGS.PlayerKey
	INNER JOIN PPG10
	ON PPGAll.PlayerKey = PPG10.PlayerKey
	INNER JOIN PPG5
	ON PPGAll.PlayerKey = PPG5.PlayerKey;
	
	IF @Debug = 1
	BEGIN

			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			ROW_NUMBER() OVER (PARTITION BY ph.PlayerKey ORDER BY ph.SeasonKey DESC, ph.GameweekKey DESC) AS GameweekInc,
			ph.TotalPoints,
			ph.[Minutes],
			ph.WasHome,
			ph.OpponentTeamKey
			FROM dbo.FactPlayerHistory ph
			WHERE ph.PlayerKey = @PlayerKey
			AND ph.[Minutes] > @MinutesLimit
			AND 
			(
				(ph.SeasonKey = @SeasonKey AND ph.GameweekKey < @GameweekKey)
				OR
				ph.SeasonKey < @SeasonKey
			);

		;WITH fnGetPlayerHistoryRankedByGameweek AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			ROW_NUMBER() OVER (PARTITION BY ph.PlayerKey ORDER BY ph.SeasonKey DESC, ph.GameweekKey DESC) AS GameweekInc,
			ph.TotalPoints,
			ph.[Minutes],
			ph.WasHome,
			ph.OpponentTeamKey
			FROM dbo.FactPlayerHistory ph
			WHERE ph.PlayerKey = @PlayerKey
			AND ph.[Minutes] > @MinutesLimit
			AND 
			(
				(ph.SeasonKey = @SeasonKey AND ph.GameweekKey < @GameweekKey)
				OR
				ph.SeasonKey < @SeasonKey
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
			WHERE ph.GameweekInc <= 38
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
		PPG5.Points AS PPG5Points,
		PPG5.Games AS PPG5Games,
		PPG5.PPG5,
		PPG10.Points AS PPG10Points,
		PPG10.Games AS PPG10Games,
		PPG10.PPG10,
		PPGS.Points AS PPGSeasonPoints,
		PPGS.Games AS PPGSeasonGames,
		PPGS.PPGSeason,
		PPGAll.PlayerKey, 
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
		ON PPGAll.PlayerKey = PPG5.PlayerKey;

	END

END