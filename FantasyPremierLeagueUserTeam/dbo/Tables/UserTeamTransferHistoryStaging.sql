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
	userteamtransferhistoryid BIGINT NOT NULL
) ON [FantasyPremierLeagueUserTeamTransferHistory];
GO

