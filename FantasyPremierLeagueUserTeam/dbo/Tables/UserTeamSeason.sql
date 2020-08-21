CREATE TABLE dbo.UserTeamSeason
(
	id INT NOT NULL,
	season_name NVARCHAR(30) NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
	seasonid INT NOT NULL,
	userteamid INT NOT NULL,
	CONSTRAINT PK_UserTeamSeason PRIMARY KEY CLUSTERED (userteamid ASC, id ASC)
	--CONSTRAINT FK_UserTeamSeason_userplayerid FOREIGN KEY (userplayerid) REFERENCES dbo.UserTeam (userPlayerid)
);
GO

--CREATE NONCLUSTERED INDEX IX_UserTeamSeason_userplayerid_inc_id ON dbo.UserTeamSeason (userplayerid) INCLUDE (id);
--GO