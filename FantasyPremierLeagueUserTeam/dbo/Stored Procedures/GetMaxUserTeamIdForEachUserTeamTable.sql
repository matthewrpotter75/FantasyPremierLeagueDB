CREATE PROCEDURE dbo.GetMaxUserTeamIdForEachUserTeamTable
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 'UserTeam' AS [Table], MAX(id) AS MaxUserTeamId
	FROM dbo.UserTeam ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.id
	)

	UNION

	SELECT 'UserTeamChip' AS [Table], MAX(userteamid) AS MaxUserTeamId
	FROM dbo.UserTeamChip ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.userteamid
	)

	UNION

	SELECT 'UserTeamCup' AS [Table], MAX(fromuserteamid) AS MaxUserTeamId
	FROM dbo.UserTeamCup ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.fromuserteamid
	)

	UNION

	SELECT 'UserTeamClassicLeague' AS [Table], MAX(userteamid) AS MaxUserTeamId
	FROM dbo.UserTeamClassicLeague ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.userteamid
	)

	UNION

	SELECT 'UserTeamGameweekHistory' AS [Table], MAX(userteamid) AS MaxUserTeamId
	FROM dbo.UserTeamGameweekHistory ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.userteamid
	)

	UNION

	SELECT 'UserTeamPick' AS [Table], MAX(userteamid) AS MaxUserTeamId
	FROM dbo.UserTeamPick ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.userteamid
	)

	UNION

	SELECT 'UserTeamSeason' AS [Table], MAX(userteamid) AS MaxUserTeamId
	FROM dbo.UserTeamSeason ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.userteamid
	)

	UNION

	SELECT 'UserTeamTransferHistory' AS [Table], MAX(userteamid) AS MaxUserTeamId
	FROM dbo.UserTeamTransferHistory ut WITH (NOLOCK)
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM dbo.UserTeam_ManualInserts
		WHERE userteamid = ut.userteamid
	);

END