CREATE PROCEDURE dbo.GetActualGameweekId
AS
BEGIN

	SET NOCOUNT ON;

	;WITH DimGameweek AS
	(
		SELECT *, DATEDIFF(DAY,GETDATE(),DeadlineTime) AS DeadlineDiff
		FROM FantasyPremierLeagueDW.dbo.DimGameweek
	)
	SELECT TOP 1 GameweekKey AS id 
	FROM DimGameweek
	ORDER BY DeadlineDiff DESC;

END