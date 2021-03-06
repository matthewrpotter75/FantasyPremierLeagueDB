CREATE PROCEDURE dbo.GetUserTeamRecordsForAllUserTeamTablesForUserTeamId
(
	@userteamid INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT *
	FROM dbo.UserTeam WITH (NOLOCK)
	WHERE id = @userteamid;

	SELECT 'UserTeamSeason';

	SELECT *
	FROM dbo.UserTeamSeason WITH (NOLOCK)
	WHERE userteamid = @userteamid;

	SELECT 'UserTeamGameweekHistory';

	SELECT *
	FROM dbo.UserTeamGameweekHistory WITH (NOLOCK)
	WHERE userteamid = @userteamid
	ORDER BY gameweekid;

	SELECT 'UserTeamTransferHistory';

	SELECT plo.web_name AS PlayerOut, pli.web_name AS PlayerIn, utth.*
	FROM dbo.UserTeamTransferHistory utth WITH (NOLOCK)
	INNER JOIN FantasyPremierLeague.dbo.Players pli
	ON utth.playerid_in = pli.id
	INNER JOIN FantasyPremierLeague.dbo.Players plo
	ON utth.playerid_out = plo.id
	WHERE userteamid = @userteamid
	ORDER BY utth.gameweekid;

	SELECT 'UserTeamPick';

	SELECT p.web_name AS PlayerName, utp.*, p.event_points
	FROM dbo.UserTeamPick utp WITH (NOLOCK)
	INNER JOIN FantasyPremierLeague.dbo.Players p
	ON utp.playerid = p.id
	WHERE userteamid = @userteamid
	ORDER BY utp.gameweekid, utp.position;

	SELECT 'UserTeamPickAutomaticSub';

	SELECT pli.web_name AS PlayerIn, plo.web_name AS PlayerOut, utpas.*
	FROM dbo.UserTeamPickAutomaticSub utpas WITH (NOLOCK)
	INNER JOIN FantasyPremierLeague.dbo.Players pli
	ON utpas.playerid_in = pli.id
	INNER JOIN FantasyPremierLeague.dbo.Players plo
	ON utpas.playerid_out = plo.id
	WHERE userteamid = @userteamid
	ORDER BY utpas.gameweekid;

	SELECT 'UserTeamClassicLeague';

	SELECT l.league_name, utcl.*
	FROM dbo.UserTeamClassicLeague utcl WITH (NOLOCK)
	INNER JOIN dbo.League l WITH (NOLOCK)
	ON utcl.leagueid = l.id
	WHERE userteamid = @userteamid;

	SELECT 'UserTeamH2hLeaague';

	SELECT *
	FROM dbo.UserTeamH2hLeague WITH (NOLOCK)
	WHERE userteamid = @userteamid;

	SELECT 'UserTeamCup';

	SELECT *
	FROM dbo.UserTeamCup WITH (NOLOCK)
	WHERE homeTeam_userTeamid = @userteamid
	OR awayTeam_userTeamid = @userteamid
	ORDER BY gameweekid;

END
