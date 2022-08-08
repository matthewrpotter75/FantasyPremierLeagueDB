CREATE TABLE dbo.UserTeamH2hLeagueStaging
(
	leagueid INT NOT NULL,
	entry_rank INT NULL,
	entry_last_rank INT NULL,
	entry_can_leave BIT NOT NULL,
	entry_can_admin BIT NOT NULL,
	entry_can_invite BIT NOT NULL,
	userteamid INT NOT NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamH2hLeagueStaging_DateInserted DEFAULT (getdate()) NOT NULL
)
ON FantasyPremierLeagueUserTeamStaging
GO