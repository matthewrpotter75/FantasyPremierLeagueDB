CREATE TABLE dbo.UserTeamPick
(
	playerid INT NOT NULL,
	position INT NOT NULL,
	multiplier INT NOT NULL,
	is_captain BIT NOT NULL,
	is_vice_captain BIT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	CONSTRAINT PK_UserTeamPick PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, position ASC) ON [PRIMARY]
	--CONSTRAINT FK_UserTeamPick_userteamid FOREIGN KEY (userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamPick_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id),
	--CONSTRAINT FK_UserTeamPick_playerid FOREIGN KEY (playerid) REFERENCES dbo.Players (id),
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IX_UserTeamPick_userteamid]
    ON [dbo].[UserTeamPick]([userteamid] ASC)
ON [PRIMARY];
GO