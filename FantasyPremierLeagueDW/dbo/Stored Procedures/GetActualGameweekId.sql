CREATE PROCEDURE dbo.GetActualGameweekId
(
	@SeasonKey INT = 16
)
AS
BEGIN

	SET NOCOUNT ON;

	;WITH DimGameweek AS
	(
		SELECT *, DATEDIFF(DAY,GETDATE(),DeadlineTime) AS DeadlineDiff
		FROM FantasyPremierLeagueDW.dbo.DimGameweek
		WHERE SeasonKey = @SeasonKey
		AND DeadlineTime < GETDATE()
	)
	SELECT TOP 1 GameweekKey AS id 
	FROM DimGameweek
	ORDER BY DeadlineDiff DESC;

END
GO