CREATE PROCEDURE dbo.GetCompletedUserTeamGameweekHistoryIds
AS
BEGIN

	SET NOCOUNT ON;

	SELECT utgh.id 
	FROM dbo.UserTeamGameweekHistory utgh 
	INNER JOIN FantasyPremierLeague.dbo.Gameweeks g 
	ON utgh.gameweekId = g.id 
	WHERE g.id = 
	(
		SELECT TOP 1 id 
		FROM FantasyPremierLeague.dbo.Gameweeks 
		WHERE deadline_time < GETDATE() 
		ORDER BY deadline_time DESC
	);

END