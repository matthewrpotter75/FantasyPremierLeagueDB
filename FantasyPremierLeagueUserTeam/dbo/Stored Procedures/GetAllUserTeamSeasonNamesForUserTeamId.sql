CREATE PROCEDURE dbo.GetAllUserTeamSeasonNamesForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT s.season_name AS [name]
	FROM dbo.UserTeamSeason uts
	INNER JOIN dbo.Season s
	ON uts.seasonid = s.seasonid
	INNER JOIN dbo.UserTeam ut 
	ON uts.userteamid = ut.id 
	WHERE ut.id = @UserTeamId;

END
GO