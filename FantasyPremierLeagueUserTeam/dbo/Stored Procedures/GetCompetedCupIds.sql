CREATE PROCEDURE dbo.GetCompetedCupIds
AS
BEGIN

	SET NOCOUNT ON;

	SELECT c.id 
	FROM dbo.UserTeamCup c 
	INNER JOIN FantasyPremierLeague.dbo.Gameweeks g 
	ON c.gameweekId = g.id 
	WHERE g.id = 
	(
		SELECT TOP 1 id 
		FROM FantasyPremierLeague.dbo.Gameweeks 
		WHERE deadline_time < GETDATE() 
		ORDER BY deadline_time DESC
	);

END