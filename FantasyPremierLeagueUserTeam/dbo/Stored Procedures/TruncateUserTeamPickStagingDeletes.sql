CREATE PROCEDURE dbo.TruncateUserTeamPickStagingDeletes
WITH EXECUTE AS 'FantasyPremierLeagueUserTeamTruncateProxy'
AS
BEGIN

	TRUNCATE TABLE dbo.UserTeamPickStagingDeletes;

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[TruncateUserTeamPickStagingDeletes] TO [FantasyPremierLeagueUserTeam]
    AS [dbo];

