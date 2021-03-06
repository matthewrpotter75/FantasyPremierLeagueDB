CREATE PROCEDURE [dbo].[GetFactPlayerTransfersForGameweek]
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

		SELECT dpp.PlayerPositionShort AS PlayerPosition, pt.PlayerTransferredOutKey, pt.PlayerTransferredInKey, pto.PlayerName AS PlayerOutName, pti.PlayerName AS PlayerInName ,pt.PlayerTransferredOutCost, pt.PlayerTransferredInCost
		FROM dbo.FactPlayerTransfers pt
		INNER JOIN dbo.DimPlayer pto
		ON pt.PlayerTransferredOutKey = pto.PlayerKey
		INNER JOIN dbo.DimPlayer pti
		ON pt.PlayerTransferredInKey = pti.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON pti.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		AND dpa.SeasonKey = @SeasonKey
		WHERE pt.UserTeamKey = @UserTeamKey
		AND pt.SeasonKey = @SeasonKey
		AND pt.GameweekKey = @GameweekKey
		ORDER BY dpp.PlayerPositionKey, pto.PlayerName;

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END