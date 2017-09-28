CREATE PROCEDURE dbo.InsertBestTeamPlayerPointsForGameweek
(
	@SeasonKey INT = NULL,
	@GameweekKey INT,
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
	;WITH PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		ph.GameweekKey, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		pgs.Cost,
		ph.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM dbo.FactPlayerHistory ph
		INNER JOIN dbo.FactPlayerGameweekStatus pgs
		ON ph.PlayerKey = pgs.PlayerKey
		AND ph.SeasonKey = pgs.SeasonKey
		AND ph.GameweekKey = pgs.GameweekKey
		INNER JOIN dbo.DimPlayer p
		ON ph.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON ph.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey = @GameweekKey
	),
	PlayersRankedExceptGKP AS
	(
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
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
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS BestOthersRank
		FROM PlayersRankedExceptGKP pr
		WHERE PlayerKey NOT IN
		(
			SELECT PlayerKey
			FROM Top3DefendersAndMidfielders
		
			UNION
		
			SELECT PlayerKey
			FROM TopStriker
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
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, 12 AS PlayerRank
		FROM TopGKP
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM Top3DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopStriker
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopBestOthers
		WHERE BestOthersRank <= 3
	)
	MERGE INTO dbo.BestTeam AS Target 
	USING 
	(
		SELECT 
		@SeasonKey AS SeasonKey,
		@GameweekKey AS GameweekKey,
		PlayerKey, 
		PlayerPositionKey,
		Cost,
		TotalPoints,
		1 AS IsPlay
		FROM Best11Players
	)
	AS Source (SeasonKey, GameweekKey, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	ON Source.SeasonKey = Target.SeasonKey
	AND Source.GameweekKey = Target.GameweekKey
	AND Source.PlayerKey = Target.PlayerKey
	AND Source.PlayerPositionKey = Target.PlayerPositionKey
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (SeasonKey, GameweekKey, PlayerKey, PlayerPositionKey, Cost, TotalPoints, IsPlay)
	VALUES (Source.SeasonKey, Source.GameweekKey, Source.PlayerKey, Source.PlayerPositionKey, Source.Cost, Source.TotalPoints, Source.IsPlay);

	UPDATE bt
	SET IsCaptain = 1
	FROM dbo.BestTeam bt
	INNER JOIN
	(
		SELECT PlayerKey,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM dbo.BestTeam
		WHERE SeasonKey = @SeasonKey
		AND GameweekKey = @GameweekKey
	) cpt
	ON cpt.PlayerKey = bt.PlayerKey
	AND cpt.PlayerRank = 1

	IF @Debug = 1
	BEGIN

		SELECT 'PlayersRankedExceptGKP';
		
		--PlayersRanked
		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		)
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
		ORDER BY PlayerPositionKey, PlayerPositionRank;

		SELECT 'Top GKP';

		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		)
		--TopGKP AS
		--(
		SELECT *
		FROM PlayersRanked
		WHERE PlayerPositionKey = 1
		AND PlayerPositionRank = 1

		SELECT 'Top 3 Defenders And Midfielders';

		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		)
		--Top3DefendersAndMidfielders AS
		--(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey IN (2,3)
		AND PlayerPositionRank <= @MinDefendersAndMidfielders;

		SELECT 'Top Striker';

		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
			FROM PlayersRanked
			WHERE PlayerPositionKey <> 1
		)
		--TopStriker AS
		--(
		SELECT *
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey = 4
		AND PlayerPositionRank = @MinForwards;		

		SELECT 'Best Others';

		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
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
		)
		SELECT PlayerKey
		FROM Top3DefendersAndMidfielders
		
		UNION
		
		SELECT PlayerKey
		FROM TopStriker;

		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
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
		)
		--TopBestOthers AS
		--(
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS BestOthersRank
		FROM PlayersRankedExceptGKP pr
		WHERE PlayerKey NOT IN
		(
			SELECT PlayerKey
			FROM Top3DefendersAndMidfielders
		
			UNION
		
			SELECT PlayerKey
			FROM TopStriker
		)
				AND 
		(
			(PlayerPositionKey = 2 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
			OR
			(PlayerPositionKey = 3 AND PlayerPositionRank <= @MaxDefendersAndMidfielders)
			OR
			(PlayerPositionKey = 4 AND PlayerPositionRank <= @MaxForwards)
		)
		ORDER BY BestOthersRank;
		--ORDER BY PlayerPositionKey, PlayerKey;

		SELECT 'Top 11 players';

		--Top 11 Players
		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			pgs.Cost,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.FactPlayerHistory ph
			INNER JOIN dbo.FactPlayerGameweekStatus pgs
			ON ph.PlayerKey = pgs.PlayerKey
			AND ph.SeasonKey = pgs.SeasonKey
			AND ph.GameweekKey = pgs.GameweekKey
			INNER JOIN dbo.DimPlayer p
			ON ph.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON ph.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		),
		PlayersRankedExceptGKP AS
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
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
			ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS BestOthersRank
			FROM PlayersRankedExceptGKP pr
			WHERE PlayerKey NOT IN
			(
				SELECT PlayerKey
				FROM Top3DefendersAndMidfielders
		
				UNION
		
				SELECT PlayerKey
				FROM TopStriker
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
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, 12 AS PlayerRank, 1 AS CodePath
		FROM TopGKP
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank, 2 AS CodePath
		FROM Top3DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank, 3 AS CodePath
		FROM TopStriker
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, Cost, TotalPoints, PlayerPositionRank, PlayerRank, 4 AS CodePath
		FROM TopBestOthers
		WHERE BestOthersRank <= 3
		ORDER BY CodePath, PlayerPositionKey, TotalPoints DESC;
		--ORDER BY PlayerPositionKey, TotalPoints DESC;

	END

END