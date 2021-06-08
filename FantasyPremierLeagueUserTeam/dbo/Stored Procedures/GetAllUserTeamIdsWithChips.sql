CREATE PROCEDURE dbo.GetAllUserTeamIdsWithChips
AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT userteamid AS id 
	FROM dbo.UserTeamChip;

END