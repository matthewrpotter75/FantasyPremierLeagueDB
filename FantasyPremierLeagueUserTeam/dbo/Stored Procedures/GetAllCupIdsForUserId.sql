CREATE PROCEDURE dbo.GetAllCupIdsForUserId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT id 
	FROM dbo.UserTeamCup 
	WHERE homeTeam_userteamid = @UserTeamId 
	OR awayTeam_userteamid = @UserTeamId;

END