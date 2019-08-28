CREATE TABLE dbo.LeagueTeamOverall
(
	id INT NOT NULL,
	userteam_name NVARCHAR(200) NOT NULL,
	gameweekid INT NOT NULL,
	player_name NVARCHAR(500) NOT NULL,
	movement NVARCHAR(10) NULL,
	is_own_entry BIT NOT NULL,
	league_rank INT NULL,
	last_rank INT NULL,
	rank_sort INT NULL,
	overall_points INT NOT NULL,
	userteamid INT NOT NULL,
	leagueid INT NOT NULL,
	start_gameweekid INT NOT NULL,
	stop_gameweekid INT NOT NULL,
	pageid INT NOT NULL,
	CONSTRAINT PK_LeagueTeamOverall PRIMARY KEY CLUSTERED (id ASC)
)
GO


