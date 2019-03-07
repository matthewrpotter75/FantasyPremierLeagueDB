CREATE PROCEDURE dbo.UpdateUserTeamPlayerIsPlayForGameweek
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@GameweekKey INT = NULL,
	@PlayerKeys VARCHAR(50) = NULL,
	@PlayerNames VARCHAR(4000) = NULL,
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

	IF @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END

	IF @UserTeamKey IS NOT NULL
	BEGIN

		UPDATE dbo.DimUserTeamPlayer
		SET IsPlay = 0
		WHERE UserTeamKey = @UserTeamKey
		AND SeasonKey = @SeasonKey
		AND GameweekKey = @GameweekKey;

		IF @PlayerKeys IS NOT NULL
		BEGIN

			IF @Debug = 1
				SELECT * FROM dbo.fnSplit(@PlayerKeys,',')

			UPDATE utp
			SET IsPlay = 1
			FROM dbo.DimUserTeamPlayer utp
			INNER JOIN dbo.fnSplit(@PlayerKeys,',') k
			ON utp.PlayerKey = k.Term
			WHERE UserTeamKey = @UserTeamKey
			AND SeasonKey = @SeasonKey
			AND GameweekKey = @GameweekKey;

		END
		ELSE
		BEGIN

			IF @Debug = 1
				SELECT * FROM dbo.fnSplit(@PlayerNames,',')

			UPDATE utp
			SET IsPlay = 1
			FROM dbo.DimUserTeamPlayer utp
			INNER JOIN dbo.DimPlayer p
			ON utp.PlayerKey = p.PlayerKey
			INNER JOIN dbo.fnSplit(@PlayerNames,',') k
			ON k.Term = p.PlayerName
			WHERE UserTeamKey = @UserTeamKey
			AND SeasonKey = @SeasonKey
			AND GameweekKey = @GameweekKey;

		END

		PRINT CAST(@@ROWCOUNT AS VARCHAR(2)) + ' players updated';

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END