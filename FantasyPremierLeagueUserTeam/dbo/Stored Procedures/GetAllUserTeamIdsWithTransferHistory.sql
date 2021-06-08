CREATE PROCEDURE dbo.GetAllUserTeamIdsWithTransferHistory
AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT userteamid AS id 
	FROM dbo.UserTeamTransferHistory;

END