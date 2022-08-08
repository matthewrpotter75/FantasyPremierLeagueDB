CREATE TABLE dbo.UserTeamSeason
(
	userteamid INT NOT NULL,
	seasonid TINYINT NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
	CONSTRAINT PK_UserTeamSeason PRIMARY KEY CLUSTERED (userteamid ASC, seasonid ASC)
	WITH (DATA_COMPRESSION = PAGE)
	ON FantasyPremierLeagueUserTeamSeason
) ON FantasyPremierLeagueUserTeamSeason;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamSeason_seasonid_INC_total_points
ON dbo.UserTeamSeason (seasonid)
INCLUDE (total_points)
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamSeason;
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_UserTeamSeason_userteamid_seasonid
ON dbo.UserTeamSeason(userteamid ASC, seasonid ASC)
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamSeason;
GO