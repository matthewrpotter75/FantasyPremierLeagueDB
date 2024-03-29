CREATE TABLE dbo.UserTeamGameweekHistoryStaging
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
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamGameweekHistoryStaging_DateInserted DEFAULT (getdate()) NOT NULL,
    CONSTRAINT PK_UserTeamGameweekHistoryStaging PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, DateInserted ASC) 
	WITH (DATA_COMPRESSION = PAGE) 
	ON FantasyPremierLeagueUserTeamGameweekHistoryStaging
) ON FantasyPremierLeagueUserTeamGameweekHistoryStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamGameweekHistoryStaging_DateInserted
    ON dbo.UserTeamGameweekHistoryStaging(DateInserted ASC)
    INCLUDE(userteamid, gameweekid, points, total_points, userteam_rank, userteam_rank_sort, userteam_overall_rank, points_on_bench) 
	WITH (DATA_COMPRESSION = PAGE)
    ON FantasyPremierLeagueUserTeamGameweekHistoryStaging;
GO

