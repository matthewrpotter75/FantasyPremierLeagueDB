CREATE PROCEDURE dbo.GetMaxGameweekIdForUserTeamIdFromUserTeamPick
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT ISNULL(MAX(gameweekid),0) 
	FROM dbo.UserTeamPick 
	WHERE userteamid = @UserTeamId;

END