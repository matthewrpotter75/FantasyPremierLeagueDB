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
)
ON FantasyPremierLeagueUserTeamStaging
GO

CREATE NONCLUSTERED INDEX IX_UserTeamGameweekHistoryStaging_userteamid_INC_gameweekid
    ON dbo.[UserTeamGameweekHistoryStaging](userteamid ASC)
    INCLUDE(gameweekid)
    ON FantasyPremierLeagueUserTeamStaging;
GO