CREATE PROCEDURE dbo.GetUserTeamTableCounts
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @RunDate DATETIME = GETDATE();

	SELECT 'UserTeam' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeam WITH (NOLOCK)

	UNION

	SELECT 'UserTeamCup' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamCup WITH (NOLOCK)

	UNION

	SELECT 'UserTeamCupTiebreak' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamCupTiebreak WITH (NOLOCK)

	UNION

	SELECT 'UserTeamClassicLeague' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamClassicLeague WITH (NOLOCK)

	UNION

	SELECT 'UserTeamH2hLeague' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamH2hLeague WITH (NOLOCK)

	UNION

	SELECT 'UserTeamSeason' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamSeason WITH (NOLOCK)

	UNION

	SELECT 'UserTeamGameweekHistory' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamGameweekHistory WITH (NOLOCK)

	UNION

	SELECT 'UserTeamChip' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamChip WITH (NOLOCK)

	UNION

	SELECT 'UserTeamTransferHistory' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamTransferHistory WITH (NOLOCK)

	UNION

	SELECT 'UserTeamPickAutomaticSub' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamPickAutomaticSub  WITH (NOLOCK)

	UNION

	SELECT 'UserTeamPick' AS Source, COUNT(*) AS TableCount, @RunDate AS CountDate
	FROM dbo.UserTeamPick WITH (NOLOCK);


END