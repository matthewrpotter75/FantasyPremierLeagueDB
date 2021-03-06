CREATE PROCEDURE dbo.UpdateUserTeamPlayerIsCaptainForGameweek
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@GameweekKey INT = NULL,
	@CaptainPlayerKey INT = NULL,
	@CaptainPlayerName VARCHAR(100) = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @GameweekKey IS NULL
	BEGIN
		SET @GameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	IF @UserTeamKey IS NULL AND @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END

	IF @CaptainPlayerKey IS NULL AND @CaptainPlayerName IS NOT NULL
	BEGIN
		SELECT @CaptainPlayerKey = PlayerKey FROM dbo.DimPlayer WHERE PlayerName = @CaptainPlayerName;
	END

	IF @CaptainPlayerName IS NULL AND @CaptainPlayerKey IS NOT NULL
	BEGIN
		SELECT @CaptainPlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @CaptainPlayerKey;
	END

	IF @UserTeamKey IS NOT NULL
	BEGIN
		
		IF @CaptainPlayerKey IS NOT NULL
		BEGIN

			UPDATE dbo.DimUserTeamPlayer
			SET IsCaptain = 0
			WHERE UserTeamKey = @UserTeamKey
			AND SeasonKey = @SeasonKey
			AND GameweekKey = @GameweekKey;

			UPDATE dbo.DimUserTeamPlayer
			SET IsCaptain = 1
			WHERE UserTeamKey = @UserTeamKey
			AND SeasonKey = @SeasonKey
			AND GameweekKey = @GameweekKey
			AND PlayerKey = @CaptainPlayerKey;

			IF @@ROWCOUNT = 1
			BEGIN
				PRINT @CaptainPlayerName + ' set as captain.';
			END
			ELSE
			BEGIN
				PRINT 'Update failed. No player set as captain. Player to be set as captain isn''t in your team.';
			END

		END
		ELSE
		BEGIN

			RAISERROR('CaptainPlayerKey is null. Check supplied CaptainPlayerKey or CaptainPlayerName!!!' , 0, 1) WITH NOWAIT;
		
		END

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END