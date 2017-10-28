CREATE PROCEDURE dbo.CopyPossibleTeamPreviousGameweekToNext
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

		SELECT p.PlayerName, @SeasonKey, @NextGameweekKey, pt.PlayerKey, pcs.Cost, pt.IsPlay, pt.IsCaptain
		FROM dbo.PossibleTeam pt
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON pt.PlayerKey = pcs.PlayerKey
		INNER JOIN dbo.DimPlayer p
		ON pt.PlayerKey = p.PlayerKey
		WHERE pt.SeasonKey = @SeasonKey
		AND pt.GameweekKey = @NextGameweekKey - 1
		ORDER BY pt.PlayerKey;

	END
	ELSE
	BEGIN

		INSERT INTO dbo.PossibleTeam
		(SeasonKey, GameweekKey, PlayerKey, Cost, IsPlay, IsCaptain)
		SELECT @SeasonKey, @NextGameweekKey, pt.PlayerKey, pcs.Cost, pt.IsPlay, pt.IsCaptain
		FROM dbo.PossibleTeam pt
		INNER JOIN dbo.FactPlayerCurrentStats pcs
		ON pt.PlayerKey = pcs.PlayerKey
		WHERE pt.SeasonKey = @SeasonKey
		AND pt.GameweekKey = @NextGameweekKey - 1;

	END

END