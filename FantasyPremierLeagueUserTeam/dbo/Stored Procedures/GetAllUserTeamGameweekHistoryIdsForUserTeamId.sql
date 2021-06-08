CREATE PROCEDURE dbo.GetAllUserTeamGameweekHistoryIdsForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT gameweekid AS id 
	FROM dbo.UserTeamGameweekHistory 
	WHERE userteamid = @UserTeamId;

END