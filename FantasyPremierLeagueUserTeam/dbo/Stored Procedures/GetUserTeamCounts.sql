CREATE PROCEDURE dbo.GetUserTeamCounts
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @RunDate DATETIME = GETDATE();

	SELECT 'UserTeam' AS Source, COUNT(DISTINCT id) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeam WITH (NOLOCK)

	UNION

	SELECT 'UserTeamCup' AS Source, COUNT(DISTINCT homeTeam_userTeamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamCup WITH (NOLOCK)

	UNION

	SELECT 'UserTeamClassicLeague' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamClassicLeague WITH (NOLOCK)

	UNION

	SELECT 'UserTeamH2hLeague' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamH2hLeague WITH (NOLOCK)

	UNION

	SELECT 'UserTeamSeason' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamSeason WITH (NOLOCK)

	UNION

	SELECT 'UserTeamGameweekHistory' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamGameweekHistory WITH (NOLOCK)

	UNION

	SELECT 'UserTeamChip' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamChip WITH (NOLOCK)

	UNION

	SELECT 'UserTeamTransferHistory' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamTransferHistory WITH (NOLOCK)

	UNION

	SELECT 'UserTeamPickAutomaticSub' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamPickAutomaticSub  WITH (NOLOCK)

	UNION

	SELECT 'UserTeamPick' AS Source, COUNT(DISTINCT userteamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamPick WITH (NOLOCK)

	UNION

	SELECT 'UserTeamCupTiebreak' AS Source, COUNT(DISTINCT utc.homeTeam_userTeamid) AS UserTeamCount, @RunDate AS CountDate
	FROM dbo.UserTeamCupTiebreak utct WITH (NOLOCK)
	INNER JOIN dbo.UserTeamCup utc WITH (NOLOCK)
	ON utct.userteamcupid = utc.id;

END