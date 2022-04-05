CREATE TABLE dbo.UserTeamSeasonStaging
(
	userteamid INT NOT NULL,
	season_name NVARCHAR(30) NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
	DateInserted  SMALLDATETIME CONSTRAINT DF_UserTeamSeasonStaging_DateInserted DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_UserTeamSeasonStaging PRIMARY KEY CLUSTERED (userteamid ASC, season_name ASC, DateInserted ASC) ON FantasyPremierLeagueUserTeamStaging
)
ON FantasyPremierLeagueUserTeamStaging
GO