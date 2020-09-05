CREATE TABLE dbo.UserTeamSeason
(
	userteamid INT NOT NULL,
	season_name NVARCHAR(30) NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
	CONSTRAINT PK_UserTeamSeason PRIMARY KEY CLUSTERED (userteamid ASC, season_name ASC)
	--CONSTRAINT FK_UserTeamSeason_userplayerid FOREIGN KEY (userplayerid) REFERENCES dbo.UserTeam (userPlayerid)
);
GO

--CREATE NONCLUSTERED INDEX IX_UserTeamSeason_userplayerid_inc_id ON dbo.UserTeamSeason (userplayerid) INCLUDE (id);
--GO

CREATE NONCLUSTERED INDEX IX_UserTeamSeason_season_name_INC_total_points
ON dbo.UserTeamSeason (season_name)
INCLUDE (total_points)
GO

CREATE NONCLUSTERED INDEX IX_UserteamSeason_userteamid
    ON dbo.UserTeamSeason(userteamid ASC);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_UserTeamSeason_userteamid_season_name
    ON dbo.UserTeamSeason(userteamid ASC, season_name ASC);
GO