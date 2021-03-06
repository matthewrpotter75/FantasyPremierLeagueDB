CREATE PROCEDURE dbo.GetAllUserTeamPickAutomaticSubIdsForUserTeamIdAndGameweekId
(
	@UserTeamId INT,
	@GameweekId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT playerid_in AS id 
	FROM dbo.UserTeamPickAutomaticSub 
	WHERE userteamid = @UserTeamId 
	AND gameweekid = @GameweekId;

END