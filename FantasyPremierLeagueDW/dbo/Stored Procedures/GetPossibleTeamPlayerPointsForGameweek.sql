CREATE PROCEDURE dbo.GetPossibleTeamPlayerPointsForGameweek
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

	IF @Debug=1
	BEGIN

		--PlayersRanked
		;WITH PlayersRanked AS
		(
			SELECT p.PlayerKey,
			p.PlayerName, 
			ph.GameweekKey, 
			pa.PlayerPositionKey,
			pp.PlayerPositionShort,
			ph.TotalPoints,
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
			--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
			FROM dbo.PossibleTeam pt
			INNER JOIN dbo.DimPlayer p
			ON pt.PlayerKey = p.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute pa
			ON pt.PlayerKey = pa.PlayerKey
			AND pa.SeasonKey = @SeasonKey
			INNER JOIN dbo.DimPlayerPosition pp
			ON pa.PlayerPositionKey = pp.PlayerPositionKey
			INNER JOIN dbo.FactPlayerHistory ph
			ON p.PlayerKey = ph.PlayerKey
			AND pt.SeasonKey = ph.SeasonKey
			AND pt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		)
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC, PlayerKey) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
		ORDER BY PlayerPositionKey, PlayerPositionRank;

	END

	--Top 11 Players
	;WITH PlayersRanked AS
	(
		SELECT p.PlayerKey,
		p.PlayerName, 
		ph.GameweekKey, 
		pa.PlayerPositionKey,
		pp.PlayerPositionShort,
		ph.TotalPoints,
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC, p.PlayerKey) AS PlayerPositionRank
		--ROW_NUMBER() OVER (ORDER BY ph.TotalPoints DESC) AS PlayerRank
		FROM dbo.PossibleTeam pt
		INNER JOIN dbo.DimPlayer p
		ON pt.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON pt.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory ph
		ON p.PlayerKey = ph.PlayerKey
		AND pt.SeasonKey = ph.SeasonKey
		AND pt.GameweekKey = ph.GameweekKey
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
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, TotalPoints, PlayerPositionRank, 12 AS PlayerRank
		FROM TopGKP
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, TotalPoints, PlayerPositionRank, PlayerRank
		FROM Top3DefendersAndMidfielders
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopStriker
		UNION
		SELECT PlayerKey, PlayerName, PlayerPositionKey, PlayerPositionShort, TotalPoints, PlayerPositionRank, PlayerRank
		FROM TopBestOthers
		WHERE BestOthersRank <= 3
	)
	SELECT PlayerKey, 
	PlayerName, PlayerPositionShort, 
	TotalPoints, 
	PlayerPositionRank, 
	PlayerRank AS PlayerRankExcGKP,
	ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PlayerRank
	FROM Best11Players
	ORDER BY PlayerPositionKey, TotalPoints DESC;

END