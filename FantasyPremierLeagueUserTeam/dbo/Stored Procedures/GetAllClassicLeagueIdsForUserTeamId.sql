CREATE PROCEDURE dbo.GetAllClassicLeagueIdsForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT leagueid AS id 
	FROM dbo.UserTeamClassicLeague 
	WHERE UserTeamId = @UserTeamId;

END