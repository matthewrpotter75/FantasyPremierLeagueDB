CREATE TABLE dbo.UserTeamGameweekHistory
(
	id INT IDENTITY(1,1) NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	points INT NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NULL,
	userteam_rank_sort INT NULL,
	userteam_overall_rank INT NULL,
	userteam_gameweek_transfers INT NOT NULL,
	userteam_gameweek_transfers_cost INT NOT NULL,
	userteam_bank INT NOT NULL,
	userteam_value INT NOT NULL,
	points_on_bench INT NOT NULL,
	CONSTRAINT PK_UserTeamGameweekHistory PRIMARY KEY CLUSTERED (userteamid ASC,gameweekid ASC, id ASC) ON FantasyPremierLeagueUserTeamGameweekHistory
	--CONSTRAINT FK_UserTeamGameweekHistory_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamGameweekHistory_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id)
) ON FantasyPremierLeagueUserTeamGameweekHistory;
GO

CREATE NONCLUSTERED INDEX [IX_UserteamGameweekHistory_userteamid]
    ON [dbo].[UserTeamGameweekHistory]([userteamid] ASC)
	ON FantasyPremierLeagueUserTeamGameweekHistory;
GO