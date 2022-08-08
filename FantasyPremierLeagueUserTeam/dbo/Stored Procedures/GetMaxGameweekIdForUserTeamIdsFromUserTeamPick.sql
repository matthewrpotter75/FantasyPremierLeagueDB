CREATE PROCEDURE dbo.GetMaxGameweekIdForUserTeamIdsFromUserTeamPick
(
	@UserTeamId1 INT = 0,
	@UserTeamId2 INT = 0,
	@UserTeamId3 INT = 0,
	@UserTeamId4 INT = 0,
	@UserTeamId5 INT = 0,
	@UserTeamId6 INT = 0,
	@UserTeamId7 INT = 0,
	@UserTeamId8 INT = 0,
	@UserTeamId9 INT = 0,
	@UserTeamId10 INT = 0,
	@UserTeamId11 INT = 0,
	@UserTeamId12 INT = 0,
	@UserTeamId13 INT = 0,
	@UserTeamId14 INT = 0,
	@UserTeamId15 INT = 0,
	@UserTeamId16 INT = 0,
	@UserTeamId17 INT = 0,
	@UserTeamId18 INT = 0,
	@UserTeamId19 INT = 0,
	@UserTeamId20 INT = 0,
	@UserTeamId21 INT = 0,
	@UserTeamId22 INT = 0,
	@UserTeamId23 INT = 0,
	@UserTeamId24 INT = 0,
	@UserTeamId25 INT = 0,
	@UserTeamId26 INT = 0,
	@UserTeamId27 INT = 0,
	@UserTeamId28 INT = 0,
	@UserTeamId29 INT = 0,
	@UserTeamId30 INT = 0,
	@UserTeamId31 INT = 0,
	@UserTeamId32 INT = 0,
	@UserTeamId33 INT = 0,
	@UserTeamId34 INT = 0,
	@UserTeamId35 INT = 0,
	@UserTeamId36 INT = 0,
	@UserTeamId37 INT = 0,
	@UserTeamId38 INT = 0,
	@UserTeamId39 INT = 0,
	@UserTeamId40 INT = 0,
	@UserTeamId41 INT = 0,
	@UserTeamId42 INT = 0,
	@UserTeamId43 INT = 0,
	@UserTeamId44 INT = 0,
	@UserTeamId45 INT = 0,
	@UserTeamId46 INT = 0,
	@UserTeamId47 INT = 0,
	@UserTeamId48 INT = 0,
	@UserTeamId49 INT = 0,
	@UserTeamId50 INT = 0,
	@UserTeamId51 INT = 0,
	@UserTeamId52 INT = 0,
	@UserTeamId53 INT = 0,
	@UserTeamId54 INT = 0,
	@UserTeamId55 INT = 0,
	@UserTeamId56 INT = 0,
	@UserTeamId57 INT = 0,
	@UserTeamId58 INT = 0,
	@UserTeamId59 INT = 0,
	@UserTeamId60 INT = 0
)
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;

	CREATE TABLE #userteam (userteamid INT);
	CREATE INDEX IDX_userteam ON #userteam (userteamid);

	INSERT INTO #userteam VALUES
	(@UserTeamId1),
	(@UserTeamId2),
	(@UserTeamId3),
	(@UserTeamId4),
	(@UserTeamId5),
	(@UserTeamId6),
	(@UserTeamId7),
	(@UserTeamId8),
	(@UserTeamId9),
	(@UserTeamId10),
	(@UserTeamId11),
	(@UserTeamId12),
	(@UserTeamId13),
	(@UserTeamId14),
	(@UserTeamId15),
	(@UserTeamId16),
	(@UserTeamId17),
	(@UserTeamId18),
	(@UserTeamId19),
	(@UserTeamId20),
	(@UserTeamId21),
	(@UserTeamId22),
	(@UserTeamId23),
	(@UserTeamId24),
	(@UserTeamId25),
	(@UserTeamId26),
	(@UserTeamId27),
	(@UserTeamId28),
	(@UserTeamId29),
	(@UserTeamId30),
	(@UserTeamId31),
	(@UserTeamId32),
	(@UserTeamId33),
	(@UserTeamId34),
	(@UserTeamId35),
	(@UserTeamId36),
	(@UserTeamId37),
	(@UserTeamId38),
	(@UserTeamId39),
	(@UserTeamId40),
	(@UserTeamId41),
	(@UserTeamId42),
	(@UserTeamId43),
	(@UserTeamId44),
	(@UserTeamId45),
	(@UserTeamId46),
	(@UserTeamId47),
	(@UserTeamId48),
	(@UserTeamId49),
	(@UserTeamId50),
	(@UserTeamId51),
	(@UserTeamId52),
	(@UserTeamId53),
	(@UserTeamId54),
	(@UserTeamId55),
	(@UserTeamId56),
	(@UserTeamId57),
	(@UserTeamId58),
	(@UserTeamId59),
	(@UserTeamId60);

	SELECT userteamid,MAX(gameweekid) AS gameweekid 
	FROM
	(
		SELECT utp.userteamid,utp.gameweekid
		FROM dbo.UserTeamPick utp WITH (NOLOCK)
		WHERE EXISTS
		(
			SELECT 1
			FROM #userteam ut
			WHERE utp.userteamid = ut.userteamid
		)

		UNION

		SELECT utp.userteamid,utp.gameweekid
		FROM dbo.UserTeamPickStaging utp WITH (NOLOCK)
		WHERE EXISTS
		(
			SELECT 1
			FROM #userteam ut
			WHERE utp.userteamid = ut.userteamid
		)
	) utpall
	GROUP BY userteamid
	OPTION (MAXDOP 1);

	DROP TABLE #userteam;

END
GO