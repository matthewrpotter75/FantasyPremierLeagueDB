CREATE PROCEDURE dbo.SetUserTeamGameweekChipForUserTeamAndGameweek
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@GameweekKey INT = NULL,
	@ChipKey INT = NULL,
	@ChipName VARCHAR(100) = NULL,
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

	IF @UserTeamKey IS NOT NULL AND @UserTeamName IS NULL
	BEGIN
		SELECT @UserTeamName = UserTeamName FROM dbo.DimUserTeam WHERE UserTeamKey = @UserTeamKey;
	END

	IF @ChipKey IS NULL AND @ChipName IS NOT NULL
	BEGIN
		SELECT @ChipKey = ChipKey FROM dbo.DimChip WHERE ChipName = @ChipName;
	END

	IF @ChipName IS NULL AND @ChipKey IS NOT NULL
	BEGIN
		SELECT @ChipName = ChipName FROM dbo.DimChip WHERE ChipKey = @ChipKey;
	END

	IF @UserTeamKey IS NOT NULL
	BEGIN
		
		IF @ChipKey IS NOT NULL
		BEGIN

			MERGE INTO dbo.DimUserTeamGameweekChip AS Target 
			USING 
			(
				VALUES(@UserTeamKey, @ChipKey, @SeasonKey, @GameweekKey)
			) Source (UserTeamKey, ChipKey, SeasonKey, GameweekKey)
			ON Source.UserTeamKey = Target.UserTeamKey
			AND Source.SeasonKey = Target.SeasonKey
			AND Source.ChipKey = Target.ChipKey
			WHEN NOT MATCHED BY Target THEN
				INSERT (UserTeamKey, ChipKey, SeasonKey, GameweekKey)
				VALUES (Source.UserTeamKey, Source.ChipKey, Source.SeasonKey, Source.GameweekKey)
			WHEN MATCHED THEN
				UPDATE
				SET GameweekKey = Source.GameweekKey;

			IF @@ROWCOUNT = 1
			BEGIN
				PRINT @ChipName + ' inserted or gameweek updated for team: ' + @UserTeamName + '.';
			END
			ELSE
			BEGIN
				PRINT 'Update failed. No chip inserted or gameweek updated for ' + @UserTeamName + '.';
			END

		END
		ELSE
		BEGIN

			RAISERROR('ChipKey is null. Check supplied ChipKey or ChipName!!!' , 0, 1) WITH NOWAIT;
		
		END

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END
GO


