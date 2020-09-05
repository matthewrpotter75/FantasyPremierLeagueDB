CREATE TABLE dbo.UserTeamTransferHistory(	id INT IDENTITY(1,1) NOT NULL,	userteamid INT NOT NULL,	transfer_time SMALLDATETIME NOT NULL,	playerid_in INT NOT NULL,	player_in_cost INT NOT NULL,	playerid_out INT NOT NULL,	player_out_cost INT NOT NULL,	gameweekid INT NOT NULL,	userteamtransferhistoryid BIGINT NOT NULL,	CONSTRAINT PK_UserTeamTransferHistory PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, id ASC)
	--CONSTRAINT FK_UserTeamTransferHistory_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamTransferHistory_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id));GO--CREATE NONCLUSTERED INDEX IX_UserTeamTransferHistory_userteamid_gameweekid ON dbo.UserTeamTransferHistory (userteamid, gameweekid);--GOCREATE NONCLUSTERED INDEX IX_UserteamTransferHistory_userteamid
    ON dbo.UserTeamTransferHistory(userteamid ASC);
GO