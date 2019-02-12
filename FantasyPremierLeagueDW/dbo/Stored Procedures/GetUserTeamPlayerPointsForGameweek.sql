CREATE PROCEDURE dbo.GetUserTeamPlayerPointsForGameweek
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@GameweekKey INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END

	IF @UserTeamKey IS NOT NULL
	BEGIN

		SELECT dpp.PlayerPositionShort AS PlayerPosition, utp.PlayerKey, dp.PlayerName, utp.IsCaptain, dp.WebName, pcs.Cost, SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.DimUserTeamPlayer utp
		INNER JOIN dbo.DimPlayer dp
		ON utp.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON dp.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON dp.PlayerKey = pcs.PlayerKey
		INNER JOIN dbo.FactPlayerHistory ph
		ON dp.PlayerKey = ph.PlayerKey
		WHERE utp.UserTeamKey = @UserTeamKey
		AND utp.SeasonKey = @SeasonKey
		AND utp.GameweekKey = @GameweekKey
		AND ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey = @GameweekKey
		AND IsPlay = 1
		GROUP BY dpp.PlayerPositionKey, dpp.PlayerPositionShort, utp.PlayerKey, dp.PlayerName, utp.IsCaptain, dp.WebName, pcs.Cost
		ORDER BY dpp.PlayerPositionKey, dp.PlayerName;

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END