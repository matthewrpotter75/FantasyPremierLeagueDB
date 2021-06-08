CREATE PROCEDURE dbo.GetAllUserTeamPickIds
AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT userteamid AS id 
	FROM dbo.UserTeamPick;

END