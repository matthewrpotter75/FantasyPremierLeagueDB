CREATE PROCEDURE dbo.GetActualGameweekId
AS
BEGIN

	SET NOCOUNT ON;

	SELECT MAX(id) AS id 
	FROM FantasyPremierLeague.dbo.Gameweeks 
	WHERE deadline_time < GETDATE();

END
GO