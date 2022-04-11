CREATE TABLE dbo.UserTeamTransferHistoryStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	userteamid INT NOT NULL,
	transfer_time SMALLDATETIME NOT NULL,
	playerid_in INT NOT NULL,
	player_in_cost INT NOT NULL,
	playerid_out INT NOT NULL,
	player_out_cost INT NOT NULL,
	gameweekid INT NOT NULL,
	userteamtransferhistoryid BIGINT NOT NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamTransferHistoryStaging_DateInserted DEFAULT (getdate()) NULL,
    CONSTRAINT PK_UserTeamTransferHistoryStaging PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, id ASC) 
	WITH (DATA_COMPRESSION = PAGE)
	ON FantasyPremierLeagueUserTeamStaging
) ON FantasyPremierLeagueUserTeamStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamTransferHistoryStaging_DateInserted_INC_player_in_cost_player_out_cost_userteamtransferhistoryid
    ON dbo.UserTeamTransferHistoryStaging(DateInserted ASC)
    INCLUDE(player_in_cost, player_out_cost, userteamtransferhistoryid)
    WITH (DATA_COMPRESSION = PAGE)
	ON FantasyPremierLeagueUserTeamStaging;
GO

--CREATE NONCLUSTERED INDEX IX_UserTeamTransferHistoryStaging_userteamid_INC_gameweekid
--    ON dbo.UserTeamTransferHistoryStaging(userteamid ASC)
--    INCLUDE(gameweekid)
--    ON FantasyPremierLeagueUserTeamTransferHistory;
--GO