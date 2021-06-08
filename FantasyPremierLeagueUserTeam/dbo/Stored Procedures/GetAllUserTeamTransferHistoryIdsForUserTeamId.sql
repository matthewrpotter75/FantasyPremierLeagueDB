CREATE PROCEDURE dbo.GetAllUserTeamTransferHistoryIdsForUserTeamId
(
	@UserTeamId INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT userteamtransferhistoryid AS id 
	FROM dbo.UserTeamTransferHistory 
	WHERE UserTeamId = @UserTeamId;

END