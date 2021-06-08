CREATE PROCEDURE dbo.GetAllUserTeamSeasonIdsForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT uts.id 
	FROM dbo.UserTeamSeason uts 
	INNER JOIN dbo.UserTeam ut 
	ON uts.userteamid = ut.id 
	WHERE ut.id = @UserTeamId;;

END