CREATE PROCEDURE dbo.GetAllUserTeamPickIdsForUserTeamIdAndGameweekId
(
	@UserTeamId INT,
	@GameweekId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT userteamid, gameweekid, position 
	FROM dbo.UserTeamPick WITH (NOLOCK)
	WHERE userteamid = @UserTeamId 
	AND gameweekid = @GameweekId;

END