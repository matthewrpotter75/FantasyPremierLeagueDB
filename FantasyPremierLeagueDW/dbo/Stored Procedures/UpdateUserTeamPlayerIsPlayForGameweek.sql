CREATE PROCEDURE dbo.UpdateUserTeamPlayerIsPlayForGameweek
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@GameweekKey INT = NULL,
	@PlayerKeys VARCHAR(50) = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL VARCHAR(1000);

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

		SET @SQL = 
		'UPDATE dbo.DimUserTeamPlayer 
		 SET IsPlay = 1
		 WHERE UserTeamKey = ' + CAST(@UserTeamKey AS VARCHAR(3)) + '
		 AND SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + '
		 AND GameweekKey = ' + CAST(@GameweekKey AS VARCHAR(3)) + '
		 AND PlayerKey IN (' + @PlayerKeys + ');';

		EXEC (@SQL);

		PRINT CAST(@@ROWCOUNT AS VARCHAR(2)) + ' players updated';

		IF @Debug = 1
			PRINT @SQL;

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END