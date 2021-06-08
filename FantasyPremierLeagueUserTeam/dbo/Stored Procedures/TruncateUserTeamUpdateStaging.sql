CREATE PROCEDURE dbo.TruncateUserTeamUpdateStaging
WITH EXECUTE AS 'FantasyPremierLeagueUserTeamTruncateProxy'
AS
BEGIN

	TRUNCATE TABLE dbo.UserTeamUpdateStaging;

END
GO


