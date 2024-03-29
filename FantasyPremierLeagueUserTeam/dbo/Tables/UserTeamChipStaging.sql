CREATE TABLE dbo.UserTeamChipStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	chip_time SMALLDATETIME NOT NULL,
	chipid INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamChipStaging_DateInserted DEFAULT (getdate()) NOT NULL,
	CONSTRAINT [PK_UserTeamChipStaging] PRIMARY KEY CLUSTERED ([userteamid] ASC, [gameweekid] ASC, [chipid] ASC, [chip_time] ASC, [DateInserted] ASC) 
	WITH (DATA_COMPRESSION = PAGE) 
	ON [FantasyPremierLeagueUserTeamStaging]
)
ON FantasyPremierLeagueUserTeamStaging
GO

CREATE NONCLUSTERED INDEX IX_UserTeamChipStaging_DateInserted
    ON dbo.UserTeamChipStaging (DateInserted ASC)
	WITH (DATA_COMPRESSION = PAGE)
    ON FantasyPremierLeagueUserTeamStaging;
GO