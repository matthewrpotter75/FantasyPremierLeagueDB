CREATE PROCEDURE dbo.CopyMyTeamPreviousGameweekToNext
(
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


	
	IF @Debug = 1
	BEGIN

		SELECT @SeasonKey AS SeasonKey, @NextGameweekKey AS GameweekKey, PlayerKey
		FROM dbo.MyTeam
		WHERE SeasonKey = @SeasonKey
		AND GameweekKey = @NextGameweekKey - 1;

	END
	ELSE
	BEGIN

		INSERT INTO dbo.MyTeam
		SELECT @SeasonKey, @NextGameweekKey, PlayerKey
		FROM dbo.MyTeam
		WHERE SeasonKey = @SeasonKey
		AND GameweekKey = @NextGameweekKey - 1;

	END

END