CREATE PROCEDURE dbo.ReplaceMyTeamPlayerWithNewPlayer
(
	@SeasonKey INT = NULL,
	@NextGameweekKey INT = NULL,
	@PlayerName VARCHAR(100) = NULL,
	@NewPlayerName VARCHAR(100) = NULL,
	@PlayerKey INT = NULL,
	@NewPlayerKey INT = NULL,
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

	IF @PlayerKey IS NULL OR @NewPlayerKey IS NULL
	BEGIN

		SELECT @PlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE PlayerName = @PlayerName;

		SELECT @NewPlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE PlayerName = @NewPlayerName;

	END

	IF (@PlayerName IS NULL AND @NewPlayerName IS NULL)
	AND (@PlayerKey IS NOT NULL AND @NewPlayerKey IS NOT NULL)
	BEGIN

		SELECT @PlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @PlayerKey
		SELECT @NewPlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @NewPlayerKey

	END


	IF @PlayerKey IS NOT NULL AND @NewPlayerKey IS NOT NULL
	BEGIN

		UPDATE dbo.MyTeam
		SET PlayerKey = @NewPlayerKey
		WHERE SeasonKey = @SeasonKey
		AND GameweekKey = @NextGameweekKey
		AND PlayerKey = @PlayerKey;

		IF @@ROWCOUNT > 0
			
			PRINT 'Transfer completed: ' + @PlayerName + ' out, ' + @NewPlayerName + ' in';

	END
	ELSE
	BEGIN
		
		IF @PlayerKey IS NULL
			PRINT 'Player: ' + @PlayerName + ' not found';

		IF @NewPlayerKey IS NULL
			PRINT 'New Player: ' + @NewPlayerName + ' not found';

	END

END