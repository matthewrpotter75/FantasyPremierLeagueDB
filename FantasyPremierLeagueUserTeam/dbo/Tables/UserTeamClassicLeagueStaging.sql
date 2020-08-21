CREATE TABLE dbo.UserTeamClassicLeagueStaging
(
	leagueid INT NOT NULL,
	entry_rank INT NULL,
	entry_last_rank INT NULL,
	entry_can_leave BIT NOT NULL,
	entry_can_admin BIT NOT NULL,
	entry_can_invite BIT NOT NULL,
	userteamid INT NOT NULL,
	CONSTRAINT PK_UserTeamClassicLeagueStaging PRIMARY KEY CLUSTERED (userteamid ASC, leagueid ASC)
	--CONSTRAINT FK_UserTeamClassicLeagueStaging_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamClassicLeagueStaging_leagueid FOREIGN KEY (leagueid) REFERENCES dbo.UserTeamLeague (id)
);
