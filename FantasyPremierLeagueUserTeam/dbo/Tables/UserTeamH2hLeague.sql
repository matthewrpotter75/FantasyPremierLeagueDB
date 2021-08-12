CREATE TABLE dbo.UserTeamH2hLeague
(
	leagueid INT NOT NULL,
	entry_rank INT NULL,
	entry_last_rank INT NULL,
	entry_can_leave BIT NOT NULL,
	entry_can_admin BIT NOT NULL,
	entry_can_invite BIT NOT NULL,
	userteamid INT NOT NULL,
	CONSTRAINT [PK_UserTeamH2hLeague] PRIMARY KEY CLUSTERED ([userteamid] ASC, [leagueid] ASC) ON [FantasyPremierLeagueUserTeamH2hLeague]
	--CONSTRAINT FK_UserTeamH2hLeague_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamH2hLeague_leagueid FOREIGN KEY (leagueid) REFERENCES dbo.UserTeamLeague (id),
	--CONSTRAINT FK_UserTeamH2hLeague_start_gameweekid FOREIGN KEY (start_gameweekid) REFERENCES dbo.Gameweeks (id)
) ON [FantasyPremierLeagueUserTeamH2hLeague];
GO

CREATE NONCLUSTERED INDEX [IX_UserTeamH2hLeague_userteamid]
    ON [dbo].[UserTeamH2hLeague]([userteamid] ASC)
	ON [FantasyPremierLeagueUserTeamH2hLeague];
GO