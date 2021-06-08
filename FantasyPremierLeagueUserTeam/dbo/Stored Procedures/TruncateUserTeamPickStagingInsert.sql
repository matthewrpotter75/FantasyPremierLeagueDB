CREATE PROCEDURE dbo.TruncateUserTeamPickStagingInsert
WITH EXECUTE AS 'FantasyPremierLeagueUserTeamTruncateProxy'
AS
BEGIN

	TRUNCATE TABLE dbo.UserTeamPickStagingInsert;

END
GO