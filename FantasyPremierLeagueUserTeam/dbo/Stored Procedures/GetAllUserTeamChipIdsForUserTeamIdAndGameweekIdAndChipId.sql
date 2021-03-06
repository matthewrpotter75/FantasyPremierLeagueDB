CREATE PROCEDURE dbo.GetAllUserTeamChipIdsForUserTeamIdAndGameweekIdAndChipId
(
	@UserTeamId INT,
	@GameweekId INT,
	@ChipId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT userteamid, gameweekid, chipid 
	FROM dbo.UserTeamChip 
	WHERE userteamid = @UserTeamId 
	AND gameweekid = @GameweekId 
	AND chipid = @ChipId;

END