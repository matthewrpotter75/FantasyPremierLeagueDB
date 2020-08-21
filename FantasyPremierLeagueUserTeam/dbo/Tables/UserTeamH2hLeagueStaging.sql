CREATE TABLE dbo.UserTeamH2hLeagueStaging
(
	id INT NOT NULL,
	entry_rank INT NULL,
	entry_last_rank INT NULL,
	entry_can_leave BIT NOT NULL,
	entry_can_admin BIT NOT NULL,
	entry_can_invite BIT NOT NULL,
	userteamid INT NOT NULL,
	CONSTRAINT PK_UserTeamH2hLeagueStaging PRIMARY KEY CLUSTERED (userteamid ASC, id ASC)
	--CONSTRAINT FK_UserTeamH2hLeagueStaging_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamH2hLeagueStaging_leagueid FOREIGN KEY (leagueid) REFERENCES dbo.UserTeamLeague (id),
);