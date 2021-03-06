CREATE TABLE dbo.UserTeamChip(	id INT IDENTITY(1,1),	chip_time SMALLDATETIME NOT NULL,	chipid INT NOT NULL,	userteamid INT NOT NULL,	gameweekid INT NOT NULL,	CONSTRAINT PK_UserTeamChip PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, chipid ASC)
	--CONSTRAINT FK_UserTeamChip_userteamid FOREIGN KEY (userTeamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamChip_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id));GO

CREATE NONCLUSTERED INDEX [IX_UserteamChip_userteamid]
    ON [dbo].[UserTeamChip]([userteamid] ASC);
GO