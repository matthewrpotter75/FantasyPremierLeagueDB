CREATE PROCEDURE dbo.GetAllUserTeams
AS
BEGIN

	SET NOCOUNT ON;

	SELECT id 
	FROM dbo.UserTeam;

END