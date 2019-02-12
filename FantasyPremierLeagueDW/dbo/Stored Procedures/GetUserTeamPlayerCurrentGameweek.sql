CREATE PROCEDURE dbo.GetUserTeamPlayerCurrentGameweek
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

		SELECT dpp.PlayerPositionShort AS PlayerPosition, utp.PlayerKey, dp.PlayerName, dp.WebName, pcs.Cost, SUM(ph.TotalPoints) AS TotalPoints
		FROM dbo.DimUserTeamPlayer utp
		INNER JOIN dbo.DimPlayer dp
		ON utp.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON dp.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON dp.PlayerKey = pcs.PlayerKey
		INNER JOIN dbo.FactPlayerHistory ph
		ON utp.PlayerKey = ph.PlayerKey
		AND ph.SeasonKey = @SeasonKey
		AND ph.GameweekKey = @CurrentGameweekKey
		WHERE utp.UserTeamKey = @UserTeamKey
		AND utp.SeasonKey = @SeasonKey
		AND utp.GameweekKey = @CurrentGameweekKey
		GROUP BY dpp.PlayerPositionKey, dpp.PlayerPositionShort, utp.PlayerKey, dp.PlayerName, dp.WebName, pcs.Cost
		ORDER BY dpp.PlayerPositionKey, dp.PlayerName;

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END