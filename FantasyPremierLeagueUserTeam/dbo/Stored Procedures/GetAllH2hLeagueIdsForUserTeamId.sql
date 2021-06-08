CREATE PROCEDURE dbo.GetAllH2hLeagueIdsForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT leagueid AS id 
	FROM dbo.UserTeamH2hLeague 
	WHERE UserTeamId = @UserTeamId;

END