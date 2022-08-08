CREATE TABLE dbo.UserTeamSeasonStaging
(
	userteamid INT NOT NULL,
	season_name NVARCHAR(30) NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
	DateInserted  SMALLDATETIME CONSTRAINT DF_UserTeamSeasonStaging_DateInserted DEFAULT (getdate()) NOT NULL
)
ON FantasyPremierLeagueUserTeamStaging
GO

CREATE NONCLUSTERED INDEX IX_UserTeamSeasonStaging_DateInserted
ON dbo.UserTeamSeasonStaging(DateInserted ASC) 
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamStaging;
GO