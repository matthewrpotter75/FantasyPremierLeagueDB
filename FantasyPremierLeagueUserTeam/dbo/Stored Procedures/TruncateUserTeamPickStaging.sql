CREATE PROCEDURE dbo.TruncateUserTeamPickStaging
WITH EXECUTE AS 'FantasyPremierLeagueUserTeamTruncateProxy'
AS
BEGIN

	TRUNCATE TABLE dbo.UserTeamPickStaging;

END