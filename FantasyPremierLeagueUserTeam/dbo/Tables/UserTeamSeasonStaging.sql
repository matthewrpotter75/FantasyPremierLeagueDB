CREATE TABLE dbo.UserTeamSeasonStaging
(
	userteamid INT NOT NULL,
	season_name NVARCHAR(30) NOT NULL,
	total_points INT NOT NULL,
	userteam_rank INT NOT NULL,
)
ON FantasyPremierLeagueUserTeamStaging
GO


