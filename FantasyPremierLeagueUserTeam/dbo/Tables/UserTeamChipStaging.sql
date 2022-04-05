CREATE TABLE dbo.UserTeamChipStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	chip_time SMALLDATETIME NOT NULL,
	chipid INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamChipStaging_DateInserted DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_UserTeamChipStaging PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, chipid ASC, chip_time ASC, DateInserted ASC) ON FantasyPremierLeagueUserTeamStaging
)
ON FantasyPremierLeagueUserTeamStaging
GO


