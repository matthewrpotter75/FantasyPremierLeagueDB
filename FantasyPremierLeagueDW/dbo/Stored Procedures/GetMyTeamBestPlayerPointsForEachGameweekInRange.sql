CREATE PROCEDURE dbo.GetMyTeamBestPlayerPointsForEachGameweekInRange
(
	@SeasonKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MinDefendersAndMidfielders INT = 3,
	@MinForwards INT = 1,
	@MaxDefendersAndMidfielders INT = 5,
	@MaxForwards INT = 3;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	--Top 11 Players
	;WITH PlayerPointsSummed AS
	(
		SELECT ph.PlayerKey,
		ph.SeasonKey,
		ph.GameweekKey,
		SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.MyTeam mt
		INNER JOIN dbo.FactPlayerHistory ph
		ON mt.PlayerKey = ph.PlayerKey
		AND mt.SeasonKey = ph.SeasonKey
		AND mt.GameweekKey = ph.GameweekKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
		GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
	),
	PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		pps.SeasonKey,
		pps.GameweekKey,
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pgs.Cost,
		pps.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM PlayerPointsSummed pps
		LEFT JOIN dbo.FactPlayerGameweekStatus pgs
		ON pps.PlayerKey = pgs.PlayerKey
		AND pgs.SeasonKey = @SeasonKey
		AND pgs.GameweekKey = @GameweekEnd
		INNER JOIN dbo.DimPlayer p
		ON pps.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON pps.PlayerKey = pa.PlayerKey
		AND pps.SeasonKey = pa.SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
	),
	PlayersRankedExceptGKP AS
	(
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
	),
	TopGKP AS
	(
		SELECT *
		FROM PlayersRanked
		WHERE PlayerPositionKey = 1
		AND PlayerPositionRank = 1
	),
	Top3DefendersAndMidfielders AS
	(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey IN (2,3)
		AND PlayerPositionRank <= @MinDefendersAndMidfielders
	),
	TopStriker AS
	(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey = 4
		AND PlayerPositionRank = @MinForwards
	),
	TopBestOthers AS
	(
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS BestOthersRank
		FROM PlayersRankedExceptGKP pr
		WHERE NOT EXISTS
		(
			SELECT SeasonKey, GameweekKey, PlayerKey
			FROM
			(
				SELECT SeasonKey, GameweekKey, PlayerKey
				FROM Top3DefendersAndMidfielders
		
				UNION
		
				SELECT SeasonKey, GameweekKey, PlayerKey
				FROM TopStriker
			) cmb
			WHERE cmb.SeasonKey = pr.SeasonKey
			AND cmb.GameweekKey = pr.GameweekKey
			AND cmb.PlayerKey = pr.PlayerKey
		)
		AND 
		(
			(PlayerPositionKey = 2 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
			OR
			(PlayerPositionKey = 3 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
			OR
			(PlayerPositionKey = 4 AND PlayerPositionRank <= @MaxForwards)
		)
	),
	Best11Players AS
	(
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, 12 AS PlayerRank
		FROM TopGKP
		UNION
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM Top3DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopStriker
		UNION
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopBestOthers
		WHERE BestOthersRank <= 3
	)
	SELECT PlayerKey, 
	PlayerName, 
	SeasonKey, 
	GameweekKey,
	PlayerPositionKey,
	PlayerPositionShort, 
	Cost,
	TotalPoints, 
	PlayerPositionRank, 
	PlayerRank AS PlayerRankExcGKP,
	ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC) AS PlayerRank
	INTO #Best11Players
	FROM Best11Players
	ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

	SELECT *
	FROM #Best11Players
	ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek
	WHERE GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	ORDER BY GameweekKey;

	IF @Debug = 1
	BEGIN
		SELECT *
		FROM @Gameweeks;
	END

	DECLARE @colHeaders VARCHAR(200),
	@sumHeaders VARCHAR(200);

	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	SELECT @sumHeaders = STUFF((SELECT  '],0) + ISNULL([' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1 , 2, '') + '],0)';

	SELECT @sumHeaders = SUBSTRING(@sumHeaders, 5, LEN(@sumHeaders)-2);

	IF @Debug = 1
	BEGIN

		SELECT @colHeaders;

		SELECT @sumHeaders;

	END

	DECLARE @sql NVARCHAR(2000);
	
	--SET @sql = 'DECLARE @CurrentGameweekKey INT;
	--SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE();

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT mt.PlayerKey,
		bp.PlayerName, 
		mt.GameweekKey, 
		bp.PlayerPositionKey,
		bp.PlayerPositionShort,
		bp.Cost,
		bp.TotalPoints
		FROM dbo.MyTeam mt
		INNER JOIN #Best11Players bp
		ON mt.PlayerKey = bp.PlayerKey
		AND mt.SeasonKey = bp.SeasonKey
		AND mt.GameweekKey = bp.GameweekKey
	)
	SELECT PlayerName, PlayerPositionShort, Cost, ' + @colHeaders + ',' + @sumHeaders + ' AS TotalPoints 
	FROM
	(
		SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, Cost, GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv
	ORDER BY PlayerPositionKey, ' + @colHeaders + ', PlayerKey;';

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT, @GameweekStart INT, @GameweekEnd INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @GameweekStart = @GameweekStart, @GameweekEnd = @GameweekEnd;

	SELECT SUM(TotalPoints) AS TotalPoints
	FROM #Best11Players;

	IF @Debug = 1
	BEGIN

		SELECT 'PlayersRankedExceptGKP';

		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.MyTeam mt
			INNER JOIN dbo.FactPlayerHistory ph
			ON mt.PlayerKey = ph.PlayerKey
			AND mt.SeasonKey = ph.SeasonKey
			AND mt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pps.SeasonKey,
			pps.GameweekKey,
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pps.SeasonKey = pgs.SeasonKey
			AND pps.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pps.SeasonKey = pa.SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		)
		--PlayersRankedExceptGKP AS
		--(
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
		ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

		SELECT 'TopGKP';

		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.MyTeam mt
			INNER JOIN dbo.FactPlayerHistory ph
			ON mt.PlayerKey = ph.PlayerKey
			AND mt.SeasonKey = ph.SeasonKey
			AND mt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pps.SeasonKey,
			pps.GameweekKey,
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pps.SeasonKey = pgs.SeasonKey
			AND pps.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pps.SeasonKey = pa.SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		)
		--TopGKP AS
		--(
		SELECT *
		FROM PlayersRanked
		WHERE PlayerPositionKey = 1
		AND PlayerPositionRank = 1
		ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

		SELECT 'Top3DefendersAndMidfielders';
		
		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.MyTeam mt
			INNER JOIN dbo.FactPlayerHistory ph
			ON mt.PlayerKey = ph.PlayerKey
			AND mt.SeasonKey = ph.SeasonKey
			AND mt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pps.SeasonKey,
			pps.GameweekKey,
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pps.SeasonKey = pgs.SeasonKey
			AND pps.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pps.SeasonKey = pa.SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		)
		--Top3DefendersAndMidfielders AS
		--(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey IN (2,3)
		AND PlayerPositionRank <= @MinDefendersAndMidfielders
		ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

		SELECT 'TopStriker';
		
		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.MyTeam mt
			INNER JOIN dbo.FactPlayerHistory ph
			ON mt.PlayerKey = ph.PlayerKey
			AND mt.SeasonKey = ph.SeasonKey
			AND mt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pps.SeasonKey,
			pps.GameweekKey,
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pps.SeasonKey = pgs.SeasonKey
			AND pps.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pps.SeasonKey = pa.SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		)
		--TopStriker AS
		--(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey = 4
		AND PlayerPositionRank = @MinForwards
		ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

		SELECT 'TopBestOthers';

		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.MyTeam mt
			INNER JOIN dbo.FactPlayerHistory ph
			ON mt.PlayerKey = ph.PlayerKey
			AND mt.SeasonKey = ph.SeasonKey
			AND mt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pps.SeasonKey,
			pps.GameweekKey,
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pps.SeasonKey = pgs.SeasonKey
			AND pps.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pps.SeasonKey = pa.SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		),
		Top3DefendersAndMidfielders AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey IN (2,3)
			AND PlayerPositionRank <= @MinDefendersAndMidfielders
		),
		TopStriker AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey = 4
			AND PlayerPositionRank = @MinForwards
		)
		--TopBestOthers AS
		--(
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS BestOthersRank
		FROM PlayersRankedExceptGKP pr
		WHERE NOT EXISTS
		(
			SELECT SeasonKey, GameweekKey, PlayerKey
			FROM
			(
				SELECT SeasonKey, GameweekKey, PlayerKey
				FROM Top3DefendersAndMidfielders
		
				UNION
		
				SELECT SeasonKey, GameweekKey, PlayerKey
				FROM TopStriker
			) cmb
			WHERE cmb.SeasonKey = pr.SeasonKey
			AND cmb.GameweekKey = pr.GameweekKey
			AND cmb.PlayerKey = pr.PlayerKey
		)
		AND 
		(
			(PlayerPositionKey = 2 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
			OR
			(PlayerPositionKey = 3 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
			OR
			(PlayerPositionKey = 4 AND PlayerPositionRank <= @MaxForwards)
		)
		ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

		SELECT 'Best11Players';
	
		;WITH PlayerPointsSummed AS
		(
			SELECT ph.PlayerKey,
			ph.SeasonKey,
			ph.GameweekKey,
			SUM(ph.TotalPoints) AS TotalPoints
			FROM dbo.MyTeam mt
			INNER JOIN dbo.FactPlayerHistory ph
			ON mt.PlayerKey = ph.PlayerKey
			AND mt.SeasonKey = ph.SeasonKey
			AND mt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
			GROUP BY ph.PlayerKey, ph.SeasonKey, ph.GameweekKey
		),
		PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			pps.SeasonKey,
			pps.GameweekKey,
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			pps.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pps.SeasonKey, pps.GameweekKey, pa.PlayerPositionKey ORDER BY pps.TotalPoints DESC, pps.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM PlayerPointsSummed pps
			LEFT JOIN dbo.FactPlayerGameweekStatus pgs
			ON pps.PlayerKey = pgs.PlayerKey
			AND pps.SeasonKey = pgs.SeasonKey
			AND pps.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON pps.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pps.PlayerKey = pa.PlayerKey
			AND pps.SeasonKey = pa.SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		),
		TopGKP AS
		(
			SELECT *
			FROM PlayersRanked
			WHERE PlayerPositionKey = 1
			AND PlayerPositionRank = 1
		),
		Top3DefendersAndMidfielders AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey IN (2,3)
			AND PlayerPositionRank <= @MinDefendersAndMidfielders
		),
		TopStriker AS
		(
			SELECT *
			FROM PlayersRankedExceptGKP
			WHERE PlayerPositionKey = 4
			AND PlayerPositionRank = @MinForwards
		),
		TopBestOthers AS
		(
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY SeasonKey, GameweekKey ORDER BY TotalPoints DESC, PlayerKey) AS BestOthersRank
			FROM PlayersRankedExceptGKP pr
			WHERE NOT EXISTS
			(
				SELECT SeasonKey, GameweekKey, PlayerKey
				FROM
				(
					SELECT SeasonKey, GameweekKey, PlayerKey
					FROM Top3DefendersAndMidfielders
		
					UNION
		
					SELECT SeasonKey, GameweekKey, PlayerKey
					FROM TopStriker
				) cmb
				WHERE cmb.SeasonKey = pr.SeasonKey
				AND cmb.GameweekKey = pr.GameweekKey
				AND cmb.PlayerKey = pr.PlayerKey
			)
			AND 
			(
				(PlayerPositionKey = 2 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
				OR
				(PlayerPositionKey = 3 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
				OR
				(PlayerPositionKey = 4 AND PlayerPositionRank <= @MaxForwards)
			)
		)
		--Best11Players AS
		--(
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, 12 AS PlayerRank
		FROM TopGKP
		UNION
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM Top3DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopStriker
		UNION
		SELECT PlayerKey, PlayerName, SeasonKey, GameweekKey, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopBestOthers
		WHERE BestOthersRank <= 3
		ORDER BY SeasonKey, GameweekKey, PlayerPositionKey, TotalPoints DESC;

	END

END