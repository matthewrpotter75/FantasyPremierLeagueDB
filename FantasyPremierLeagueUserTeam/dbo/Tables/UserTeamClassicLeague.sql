CREATE TABLE dbo.UserTeamClassicLeague
(
	leagueid INT NOT NULL,
	entry_rank INT NULL,
	entry_last_rank INT NULL,
	entry_can_leave BIT NOT NULL,
	entry_can_admin BIT NOT NULL,
	entry_can_invite BIT NOT NULL,
	userteamid INT NOT NULL,
	CONSTRAINT PK_UserTeamClassicLeague PRIMARY KEY CLUSTERED (userteamid ASC, leagueid ASC)
	WITH (DATA_COMPRESSION = PAGE)
	ON FantasyPremierLeagueUserTeamClassicLeague
	--CONSTRAINT FK_UserTeamClassicLeague_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamClassicLeague_leagueid FOREIGN KEY (leagueid) REFERENCES dbo.UserTeamLeague (id)
) ON FantasyPremierLeagueUserTeamClassicLeague;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamClassicLeague_userteamid
    ON dbo.UserTeamClassicLeague(userteamid ASC)
	WITH (DATA_COMPRESSION = PAGE)
	ON FantasyPremierLeagueUserTeamClassicLeague;;
GO