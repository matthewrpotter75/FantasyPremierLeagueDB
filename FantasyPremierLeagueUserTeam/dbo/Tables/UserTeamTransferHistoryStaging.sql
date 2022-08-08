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
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamTransferHistoryStaging_DateInserted DEFAULT (getdate()) NOT NULL
) 
ON FantasyPremierLeagueUserTeamStaging
WITH (DATA_COMPRESSION = PAGE);
GO

CREATE NONCLUSTERED INDEX IX_UserTeamTransferHistoryStaging_DateInserted_INC_userteamid_player_in_cost_player_out_cost_userteamtransferhistoryid
ON dbo.UserTeamTransferHistoryStaging(DateInserted ASC)
INCLUDE(userteamid, player_in_cost, player_out_cost, userteamtransferhistoryid)
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamStaging;
GO