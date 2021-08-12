--CREATE PROCEDURE dbo.GetLatestGameweekId
--AS
--BEGIN

--	SET NOCOUNT ON;

--	SELECT MAX(gameweekId) 
--	FROM 
--	(
--		SELECT gwf.gameweekId, MAX(gwf.kickoff_time) AS MaxKickoffTime 
--		FROM FantasyPremierLeague.dbo.Gameweeks gw 
--		INNER JOIN FantasyPremierLeague.dbo.GameweekFixtures gwf 
--		ON gw.id = gwf.gameweekId 
--		GROUP BY gwf.gameweekId 
--	) t 
--	WHERE DATEADD(hh,9,CAST(CAST(DATEADD(day,1,MaxKickoffTime) AS DATE) AS DATETIME)) < GETDATE();

--END