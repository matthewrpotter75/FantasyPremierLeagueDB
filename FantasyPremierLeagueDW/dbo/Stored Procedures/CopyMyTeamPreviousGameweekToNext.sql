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

		SELECT @SeasonKey, @NextGameweekKey, mt.PlayerKey, pgs.Cost, mt.IsPlay, mt.IsCaptain
		FROM dbo.MyTeam mt
		INNER JOIN dbo.FactPlayerGameweekStatus pgs
		ON mt.PlayerKey = pgs.PlayerKey
		WHERE mt.SeasonKey = @SeasonKey
		AND mt.GameweekKey = @NextGameweekKey - 1;

	END
	ELSE
	BEGIN

		INSERT INTO dbo.MyTeam
		(SeasonKey, GameweekKey, PlayerKey, Cost, IsPlay, IsCaptain)
		SELECT @SeasonKey, @NextGameweekKey, mt.PlayerKey, pgs.Cost, mt.IsPlay, mt.IsCaptain
		FROM dbo.MyTeam mt
		INNER JOIN dbo.FactPlayerGameweekStatus pgs
		ON mt.PlayerKey = pgs.PlayerKey
		WHERE mt.SeasonKey = @SeasonKey
		AND mt.GameweekKey = @NextGameweekKey - 1;

	END

END