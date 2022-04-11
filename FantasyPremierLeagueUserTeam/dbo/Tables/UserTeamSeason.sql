CREATE TABLE dbo.UserTeamSeason
(
	userteamid INT NOT NULL,
	seasonid TINYINT NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
	CONSTRAINT PK_UserTeamSeason PRIMARY KEY CLUSTERED (userteamid ASC, seasonid ASC) 
	WITH (DATA_COMPRESSION = PAGE)
	ON FantasyPremierLeagueUserTeamSeason
	--CONSTRAINT FK_UserTeamSeason_userplayerid FOREIGN KEY (userplayerid) REFERENCES dbo.UserTeam (userPlayerid)
) ON FantasyPremierLeagueUserTeamSeason;
GO

--CREATE NONCLUSTERED INDEX IX_UserTeamSeason_userplayerid_inc_id ON dbo.UserTeamSeason (userplayerid) INCLUDE (id);
--GO

--CREATE NONCLUSTERED INDEX IX_UserTeamSeason_seasonid_INC_total_points
--	ON dbo.UserTeamSeason (seasonid)
--	INCLUDE (total_points)
--ON FantasyPremierLeagueUserTeamSeason;
--GO

--CREATE NONCLUSTERED INDEX IX_UserTeamSeason_userteamid
--    ON dbo.UserTeamSeason(userteamid ASC)
--ON [FantasyPremierLeagueUserTeamSeason];
--GO

--CREATE UNIQUE NONCLUSTERED INDEX UX_UserTeamSeason_userteamid_seasonid
--    ON dbo.UserTeamSeason(userteamid ASC, seasonid ASC)
--ON [FantasyPremierLeagueUserTeamSeason];
--GO