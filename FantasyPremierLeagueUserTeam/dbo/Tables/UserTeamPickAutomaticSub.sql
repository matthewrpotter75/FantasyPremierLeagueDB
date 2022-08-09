CREATE TABLE dbo.UserTeamPickAutomaticSub(	id INT IDENTITY (1, 1) NOT NULL,	playerid_in INT NOT NULL,	playerid_out INT NOT NULL,	userteamid INT NOT NULL,	gameweekid INT NOT NULL,
	CONSTRAINT PK_UserTeamPickAutomaticSub PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, playerid_in ASC) 
	WITH (DATA_COMPRESSION = PAGE) 
	ON FantasyPremierLeagueUserTeamPickAutomaticSub
	--CONSTRAINT FK_UserTeamPickAutomaticSub_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamPickAutomaticSub_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id),	--CONSTRAINT FK_UserTeamPickAutomaticSub_playerid_in FOREIGN KEY (playerid_in) REFERENCES dbo.Players (id),	--CONSTRAINT FK_UserTeamPickAutomaticSub_playerid_out FOREIGN KEY (playerid_out) REFERENCES dbo.Players (id))
ON FantasyPremierLeagueUserTeamPickAutomaticSub;
GO--CREATE INDEX IX_UserTeamPickAutomaticSub_userteamid_gameweekid --ON dbo.UserTeamPickAutomaticSub (userteamid, gameweekid);--GO

CREATE NONCLUSTERED INDEX IX_UserteamPickAutomaticSub_userteamid
ON dbo.UserTeamPickAutomaticSub(userteamid ASC)
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamPickAutomaticSub;
GO