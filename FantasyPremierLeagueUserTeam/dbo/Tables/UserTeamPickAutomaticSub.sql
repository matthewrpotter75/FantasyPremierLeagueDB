CREATE TABLE dbo.UserTeamPickAutomaticSub
	CONSTRAINT PK_UserTeamPickAutomaticSub PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, playerid_in ASC)
	--CONSTRAINT FK_UserTeamPickAutomaticSub_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamPickAutomaticSub_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id),