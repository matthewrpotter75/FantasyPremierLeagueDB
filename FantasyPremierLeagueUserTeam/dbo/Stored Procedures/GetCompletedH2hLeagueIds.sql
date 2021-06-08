CREATE PROCEDURE dbo.GetCompletedH2hLeagueIds
AS
BEGIN

	SET NOCOUNT ON;

	SELECT h.leagueid AS id
	FROM dbo.UserTeamH2hLeague h 
	INNER JOIN FantasyPremierLeague.dbo.Gameweeks g 
	ON h.gameweekId = g.id 
	WHERE g.id = 
	(
		SELECT TOP 1 id 
		FROM FantasyPremierLeague.dbo.Gameweeks 
		WHERE deadline_time < GETDATE() 
		ORDER BY deadline_time DESC
	);

END