CREATE TABLE dbo.UserTeamPickStaging
(
	playerid INT NOT NULL,
	position INT NOT NULL,
	multiplier INT NOT NULL,
	is_captain BIT NOT NULL,
	is_vice_captain BIT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
    DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamPickStaging_DateInserted DEFAULT (getdate()) NOT NULL,
    CONSTRAINT PK_UserTeamPickStaging PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, position ASC, DateInserted ASC) ON FantasyPremierLeagueUserTeamPickStaging
) ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPickStaging_userteamid_gameweekid_position_DateInserted_INC_playerid
    ON dbo.UserTeamPickStaging(userteamid ASC, gameweekid ASC, position ASC, DateInserted ASC)
    INCLUDE(playerid)
    ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPickStaging_userteamid_INC_gameweekid
    ON dbo.UserTeamPickStaging(userteamid ASC)
    INCLUDE(gameweekid)
    ON FantasyPremierLeagueUserTeamPickStaging;
GO