CREATE PROCEDURE dbo.GetAllUserTeamChipIdsForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT userteamid, gameweekid, chipid 
	FROM dbo.UserTeamChip WiTH (NOLOCK)
	WHERE userteamid = @UserTeamId;

END