CREATE PROCEDURE dbo.GetAllUserTeamSeasonNamesForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT uts.season_name AS [name]
	FROM dbo.UserTeamSeason uts 
	INNER JOIN dbo.UserTeam ut 
	ON uts.userteamid = ut.id 
	WHERE ut.id = @UserTeamId;;

END