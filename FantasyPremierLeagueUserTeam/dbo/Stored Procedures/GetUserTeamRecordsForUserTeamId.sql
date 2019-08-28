CREATE PROCEDURE dbo.GetUserTeamRecordsForUserTeamId
(
	@userteamid INT
)
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT 'UserTeam';

	SELECT *
	FROM dbo.UserTeam
	WHERE id = @UserTeamId;

	SELECT 'UserTeamCup';

	SELECT *
	FROM dbo.UserTeamCup
	WHERE homeTeam_userTeamid = @UserTeamId OR awayTeam_userTeamid = @UserTeamId;

	SELECT 'UserTeamClassicLeague';

	SELECT *
	FROM dbo.UserTeamClassicLeague
	WHERE userteamid = @UserTeamId;

	SELECT 'UserTeamH2hLeague';

	SELECT *
	FROM dbo.UserTeamH2hLeague
	WHERE userteamid = @UserTeamId;

	SELECT 'UserTeamChip';

	SELECT *
	FROM dbo.UserTeamChip
	WHERE userteamid = @UserTeamId;

	SELECT 'UserTeamSeason';

	SELECT uts.*
	FROM dbo.UserTeamSeason uts
	INNER JOIN dbo.UserTeam ut
	ON uts.userplayerid = ut.userPlayerid
	WHERE ut.id = @UserTeamId;

	SELECT 'UserTeamGameweekHistory';

	SELECT gameweekid,*
	FROM dbo.UserTeamGameweekHistory
	WHERE userteamid = @UserTeamId;

	SELECT 'UserTeamTransferHistory';

	SELECT utth.*, playerout.web_name AS PlayerOut, playerin.web_name AS PlayerIn
	FROM dbo.UserTeamTransferHistory utth
	INNER JOIN [$(FantasyPremierLeague)].dbo.Players playerin
	ON utth.playerid_in = playerin.id
	INNER JOIN [$(FantasyPremierLeague)].dbo.Players playerout
	ON utth.playerid_out = playerout.id
	WHERE userteamid = @UserTeamId
	ORDER BY utth.gameweekid;

	SELECT 'UserTeamPick';

	SELECT utp.*, p.web_name AS PlayerName
	FROM dbo.UserTeamPick utp
	INNER JOIN [$(FantasyPremierLeague)].dbo.Players p
	ON utp.playerid = p.id
	WHERE userteamid = @UserTeamId
	ORDER BY utp.gameweekid, utp.position;

	SELECT 'UserTeamPickAutomaticSub';

	SELECT utpas.*, playerout.web_name AS PlayerOutName, playerin.web_name AS PlayerInName
	FROM dbo.UserTeamPickAutomaticSub utpas
	INNER JOIN [$(FantasyPremierLeague)].dbo.Players playerin
	ON utpas.playerid_in = playerin.id
	INNER JOIN [$(FantasyPremierLeague)].dbo.Players playerout
	ON utpas.playerid_out = playerout.id
	WHERE utpas.userteamid = @UserTeamId
	ORDER BY utpas.gameweekid, utpas.id;

END