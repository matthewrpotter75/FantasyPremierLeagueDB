CREATE PROCEDURE dbo.CopyUserTeamPlayerPreviousGameweekToNext
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@NextGameweekKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @LastGameweekKey INT;
	IF @NextGameweekKey IS NULL
	BEGIN
		SET @NextGameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	IF @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END
	
	IF @Debug = 1
	BEGIN

		SELECT p.PlayerName, @SeasonKey, @NextGameweekKey, mt.PlayerKey, pcs.Cost, mt.IsPlay, mt.IsCaptain
		FROM dbo.DimUserTeamPlayer mt
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON mt.PlayerKey = pcs.PlayerKey
		INNER JOIN dbo.DimPlayer p
		ON mt.PlayerKey = p.PlayerKey
		WHERE mt.UserTeamKey = @UserTeamKey
		AND mt.SeasonKey = @SeasonKey
		AND mt.GameweekKey = @NextGameweekKey - 1
		ORDER BY mt.PlayerKey;

	END
	ELSE
	BEGIN

		IF @UserTeamKey IS NOT NULL
		BEGIN

			INSERT INTO dbo.DimUserTeamPlayer
			(SeasonKey, GameweekKey, PlayerKey, Cost, IsPlay, IsCaptain)
			SELECT @SeasonKey, @NextGameweekKey, mt.PlayerKey, pcs.Cost, mt.IsPlay, mt.IsCaptain
			FROM dbo.DimUserTeamPlayer mt
			INNER JOIN dbo.FactPlayerCurrentStats pcs
			ON mt.PlayerKey = pcs.PlayerKey
			WHERE mt.UserTeamKey = @UserTeamKey
			AND mt.SeasonKey = @SeasonKey
			AND mt.GameweekKey = @NextGameweekKey - 1;

		END
		ELSE
		BEGIN

			RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

		END

	END

END