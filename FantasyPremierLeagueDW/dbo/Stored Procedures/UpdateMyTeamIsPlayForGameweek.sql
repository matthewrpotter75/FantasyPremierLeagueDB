CREATE PROCEDURE dbo.UpdateMyTeamIsPlayForGameweek
(
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

	SET @SQL = 
	'UPDATE dbo.MyTeam 
	 SET IsPlay = 1
	 WHERE SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + '
	 AND GameweekKey = ' + CAST(@GameweekKey AS VARCHAR(3)) + '
	 AND PlayerKey IN (' + @PlayerKeys + ');';

	EXEC (@SQL);

	PRINT CAST(@@ROWCOUNT AS VARCHAR(2)) + ' players updated';

	PRINT @SQL;

END