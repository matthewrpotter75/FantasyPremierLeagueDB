CREATE TABLE dbo.LeagueTeamOverall
(
	id INT NOT NULL,
	userteamid INT NOT NULL,
	league_rank INT NULL,
	last_rank INT NULL,
	rank_sort INT NULL,
	gameweek_points INT NOT NULL,
	overall_points INT NOT NULL,
	leagueid INT NOT NULL,
	pageid INT NOT NULL,
	CONSTRAINT PK_LeagueTeamOverall PRIMARY KEY CLUSTERED (id ASC)
)
GO