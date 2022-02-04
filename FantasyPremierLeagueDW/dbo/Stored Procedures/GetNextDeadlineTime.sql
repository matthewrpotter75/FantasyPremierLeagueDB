CREATE PROCEDURE dbo.GetNextDeadlineTime
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
		WHERE SeasonKey = 16--@SeasonKey
		AND DeadlineTime > GETDATE()
	)
	SELECT TOP 1 DeadlineTime AS id 
	FROM DimGameweek
	ORDER BY DeadlineDiff;

END
GO