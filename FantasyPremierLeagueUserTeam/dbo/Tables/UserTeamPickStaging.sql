CREATE TABLE dbo.UserTeamPickStaging
(
	playerid INT NOT NULL,
	position INT NOT NULL,
	multiplier INT NOT NULL,
	is_captain BIT NOT NULL,
	is_vice_captain BIT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
    DateInserted DATETIME DEFAULT (getdate()) NULL
);
GO

CREATE NONCLUSTERED INDEX [IX_UserTeamPickStaging_userteamid_gameweekid_playerid]
    ON [dbo].[UserTeamPickStaging]([userteamid] ASC, [gameweekid] ASC, [playerid] ASC);
GO
