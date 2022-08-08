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
    DeleteFlag BIT CONSTRAINT DF_UserTeamPickStaging_DeleteFlag DEFAULT ((0)) NULL
)
ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPick_DeleteFlag
ON dbo.UserTeamPickStaging(DeleteFlag ASC) 
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPickStaging_DateInserted
ON dbo.UserTeamPickStaging(DateInserted ASC) 
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPickStaging_userteamid_gameweekid_position_DateInserted_INC_playerid
ON dbo.UserTeamPickStaging(userteamid ASC, gameweekid ASC, position ASC, DateInserted ASC)
INCLUDE(playerid) 
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPickStaging_userteamid_INC_gameweekid
ON dbo.UserTeamPickStaging(userteamid ASC)
INCLUDE(gameweekid) 
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamPickStaging;
GO