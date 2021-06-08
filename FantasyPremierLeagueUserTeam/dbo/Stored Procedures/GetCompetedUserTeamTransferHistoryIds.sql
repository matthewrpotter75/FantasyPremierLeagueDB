CREATE PROCEDURE dbo.GetCompetedUserTeamTransferHistoryIds
AS
BEGIN

	SET NOCOUNT ON;

	SELECT utth.id 
	FROM dbo.UserTeamTransferHistory utth 
	INNER JOIN FantasyPremierLeague.dbo.Gameweeks g 
	ON utth.gameweekId = g.id 
	WHERE g.id = 
	(
		SELECT TOP 1 id 
		FROM FantasyPremierLeague.dbo.Gameweeks 
		WHERE deadline_time < GETDATE() 
		ORDER BY deadline_time DESC
	);

END