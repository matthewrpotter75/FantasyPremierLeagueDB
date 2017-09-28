CREATE PROCEDURE dbo.GetPossibleTeamPlayerPointsForGameweek
(
	@SeasonKey INT = NULL,
	@GameweekKey INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MinDefenders INT = 3,
	@MinMidfielders INT = 3,
	@MinForwards INT = 1;

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
			ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC) AS PlayerPositionRank
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
			AND pt.GameweekKey = ph.GameweekKey
			WHERE ph.SeasonKey = @SeasonKey
			AND ph.GameweekKey = @GameweekKey
		)
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PlayerRank
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
		ROW_NUMBER() OVER (PARTITION BY pa.PlayerPositionKey ORDER BY ph.TotalPoints DESC) AS PlayerPositionRank
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
		AND pt.GameweekKey = ph.GameweekKey
		WHERE ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey = @GameweekKey
	),
	PlayersRankedExceptGKP AS
	(
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS PlayerRank
		FROM PlayersRanked
		WHERE PlayerPositionKey <> 1
	),
	TopGKP AS
	(
		SELECT *,
		0 AS BestOthersRank
		FROM PlayersRanked
		WHERE PlayerPositionKey = 1
		AND PlayerPositionRank = 1
	),
	Top3DefendersAndMidfielders AS
	(
		SELECT *,
		0 AS BestOthersRank
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey IN (2,3)
		AND PlayerPositionRank <= 3	
	),
	TopStriker AS
	(
		SELECT *,
		0 AS BestOthersRank
		FROM PlayersRankedExceptGKP
		WHERE PlayerPositionKey = 4
		AND PlayerPositionRank = 1
	),
	TopBestOthers AS
	(
		SELECT *,
		ROW_NUMBER() OVER (ORDER BY TotalPoints DESC) AS BestOthersRank
		FROM PlayersRankedExceptGKP pr
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM Top3DefendersAndMidfielders
			WHERE PlayerKey = pr.PlayerKey
		)
		AND NOT EXISTS
		(
			SELECT 1
			FROM TopStriker
			WHERE PlayerKey = pr.PlayerKey
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