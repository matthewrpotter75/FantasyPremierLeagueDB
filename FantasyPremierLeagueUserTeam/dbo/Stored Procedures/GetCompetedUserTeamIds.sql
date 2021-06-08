CREATE PROCEDURE dbo.GetCompetedUserTeamIds
AS
BEGIN

	SET NOCOUNT ON;

	SELECT ut.id 
	FROM dbo.UserTeam ut 
	INNER JOIN FantasyPremierLeague.dbo.Gameweeks g 
	ON ut.current_gameweekId = g.id 
	WHERE g.id = 
	(
		SELECT TOP 1 id 
		FROM FantasyPremierLeague.dbo.Gameweeks 
		WHERE deadline_time < GETDATE() 
		ORDER BY deadline_time DESC
	);

END