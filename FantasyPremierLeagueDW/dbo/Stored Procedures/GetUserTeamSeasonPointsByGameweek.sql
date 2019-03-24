CREATE PROCEDURE dbo.GetUserTeamSeasonPointsByGameweek
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@CurrentGameweekKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TripleCaptainChipKey INT,
			@BenchBoostChipKey INT;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END

	IF @CurrentGameweekKey IS NULL
	BEGIN
		SET @CurrentGameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.DimUserTeamPlayer WHERE SeasonKey = @SeasonKey ORDER BY GameweekKey DESC);
	END
	
	IF @UserTeamKey IS NOT NULL
	BEGIN

		SELECT @TripleCaptainChipKey = ChipKey
		FROM dbo.DimChip
		WHERE ChipName = 'Triple Captain';

		SELECT @BenchBoostChipKey = ChipKey
		FROM dbo.DimChip
		WHERE ChipName = 'Bench Boost';
		
		;WITH PlayerGameweekPoints AS
		(
			SELECT utp.SeasonKey,
			utp.GameweekKey,
			CASE
				WHEN utp.IsPlay = 1 AND utp.IsCaptain = 1 AND utgc.ChipKey = @TripleCaptainChipKey THEN ph.TotalPoints * 3
				WHEN utp.IsPlay = 1 AND utp.IsCaptain = 1 THEN ph.TotalPoints * 2
				WHEN utp.IsPlay = 1 THEN ph.TotalPoints
				ELSE 0
			END AS PlayerPoints,
			CASE
				WHEN utp.IsPlay = 0 THEN ph.TotalPoints
				ELSE 0
			END AS BenchPoints
			FROM dbo.DimUserTeamPlayer utp
			INNER JOIN dbo.FactPlayerHistory ph
			ON utp.PlayerKey = ph.PlayerKey
			AND utp.SeasonKey = ph.SeasonKey
			AND utp.GameweekKey = ph.GameweekKey
			LEFT JOIN dbo.DimUserTeamGameweekChip utgc
			ON utp.SeasonKey = utgc.SeasonKey
			AND utp.GameweekKey = utgc.GameweekKey
			WHERE utp.UserTeamKey = @UserTeamKey
			AND utp.SeasonKey = @SeasonKey
		),
		GameweekGames AS
		(
			SELECT SeasonKey,
			GameweekKey,
			COUNT(*) AS NumGames
			FROM dbo.FactGameweekFixture
			WHERE SeasonKey = @SeasonKey
			GROUP BY SeasonKey, GameweekKey
		),
		PlayerPoints AS
		(
			SELECT pgp.SeasonKey,
			pgp.GameweekKey,
			SUM(pgp.PlayerPoints) AS GameweekPoints,
			SUM(pgp.BenchPoints) AS BenchPoints
			FROM PlayerGameweekPoints pgp
			GROUP BY pgp.SeasonKey, pgp.GameweekKey			
		)
		SELECT 'GW' + CAST(pp.GameweekKey AS VARCHAR(4)) AS Gameweek,
		CASE
			WHEN utgc.ChipKey = @BenchBoostChipKey THEN pp.GameweekPoints + pp.BenchPoints
			ELSE pp.GameweekPoints
		END AS GameweekPoints,
		CASE
			WHEN utgc.ChipKey = @BenchBoostChipKey THEN 0
			ELSE pp.BenchPoints
		END	BenchPoints,
		pp.GameweekPoints - utft.TransferCost AS FinalGameweekPoints,
		utft.TransferCount,
		utft.TransferCost,
		SUM(pp.GameweekPoints - utft.TransferCost) OVER(ORDER BY pp.GameweekKey ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS OverallPoints,
		gg.NumGames,
		CASE 
			WHEN gg.NumGames < 10 THEN 'BGW'
			WHEN gg.NumGames > 10 THEN 'DGW'
			ELSE ''
		END AS GameweekType,
		ISNULL(c.ChipName,'') AS ChipPlayed
		FROM PlayerPoints pp
		INNER JOIN dbo.fnGetUserTeamFreeTransfers(@SeasonKey, @UserTeamKey) utft
		ON pp.SeasonKey = utft.SeasonKey
		AND pp.GameweekKey = utft.GameweekKey
		INNER JOIN GameweekGames gg
		ON pp.SeasonKey = gg.SeasonKey
		AND pp.GameweekKey = gg.GameweekKey
		LEFT JOIN dbo.DimUserTeamGameweekChip utgc
		ON pp.SeasonKey = utgc.SeasonKey
		AND pp.GameweekKey = utgc.GameweekKey
		LEFT JOIN dbo.DimChip c
		ON utgc.ChipKey = c.ChipKey
		ORDER BY pp.GameweekKey;

		IF @Debug = 1
		BEGIN

			SELECT *
			FROM dbo.fnGetUserTeamFreeTransfers(@SeasonKey, @UserTeamKey);

			SELECT utp.SeasonKey,
			utp.GameweekKey,
			CASE
				WHEN utp.IsPlay = 1 AND utp.IsCaptain = 1 THEN ph.TotalPoints * 2
				WHEN utp.IsPlay = 1 AND utp.IsCaptain = 1 AND utgc.ChipKey = @TripleCaptainChipKey THEN ph.TotalPoints * 3
				WHEN utp.IsPlay = 1 THEN ph.TotalPoints
				ELSE 0
			END AS PlayerPoints,
			CASE
				WHEN utp.IsPlay = 0 THEN ph.TotalPoints
				ELSE 0
			END AS BenchPoints
			FROM dbo.DimUserTeamPlayer utp
			INNER JOIN dbo.FactPlayerHistory ph
			ON utp.PlayerKey = ph.PlayerKey
			AND utp.SeasonKey = ph.SeasonKey
			AND utp.GameweekKey = ph.GameweekKey
			LEFT JOIN dbo.DimUserTeamGameweekChip utgc
			ON utp.SeasonKey = utgc.SeasonKey
			AND utp.GameweekKey = utgc.GameweekKey
			WHERE utp.UserTeamKey = @UserTeamKey
			AND utp.SeasonKey = @SeasonKey;

		END

	END

END