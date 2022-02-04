CREATE PROCEDURE dbo.GetLatestGameweekId
(
	@SeasonKey INT = 16
)
AS
BEGIN

	SET NOCOUNT ON;

	;WITH DimGameweek AS
	(
		SELECT gw.SeasonKey, gw.GameweekKey, gwf.KickoffTime, 
		DATEDIFF(HOUR,GETDATE(),DATEADD(hh,9,CAST(CAST(DATEADD(DAY,1,gwf.KickoffTime) AS DATE) AS DATETIME))) AS DeadlineDiff
		FROM FantasyPremierLeagueDW.dbo.DimGameweek gw 
		INNER JOIN FantasyPremierLeagueDW.dbo.FactGameweekFixture gwf 
		ON gw.SeasonKey = gwf.SeasonKey
		AND gw.GameweekKey = gwf.GameweekKey
		WHERE gw.SeasonKey = @SeasonKey
		AND gwf.KickoffTime < GETDATE()
	)
	SELECT TOP 1 GameweekKey AS id 
	FROM DimGameweek
	ORDER BY DeadlineDiff DESC;

END
GO