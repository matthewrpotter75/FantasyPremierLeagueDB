CREATE PROCEDURE dbo.GetLatestUserTeamChipUserTeamId
AS
BEGIN

	SET NOCOUNT ON;

	SELECT MAX(userteamid) AS id 
	FROM dbo.UserTeamChip utc 
	WHERE NOT EXISTS 
	(
		SELECT 1 
		FROM dbo.UserTeam_ManualInserts 
		WHERE userteamid = utc.userteamid
	);

END