CREATE TABLE dbo.UserTeamPickAutomaticSubStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	playerid_in INT NOT NULL,
	playerid_out INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamPickAutomaticSubStaging_DateInserted DEFAULT (getdate()) NOT NULL,
    CONSTRAINT PK_UserTeamPickAutomaticSubStaging PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, playerid_in ASC, DateInserted ASC) ON FantasyPremierLeagueUserTeamPickStaging
) ON FantasyPremierLeagueUserTeamPickStaging;
GO