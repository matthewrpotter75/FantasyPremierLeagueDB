CREATE TABLE dbo.UserTeamPickAutomaticSubStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	playerid_in INT NOT NULL,
	playerid_out INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamPickAutomaticSubStaging_DateInserted DEFAULT (getdate()) NOT NULL,
)
ON FantasyPremierLeagueUserTeamPickStaging;
GO

CREATE NONCLUSTERED INDEX IX_UserTeamPickAutomaticSubStaging_DateInserted
ON dbo.UserTeamPickAutomaticSubStaging(DateInserted ASC) 
WITH (DATA_COMPRESSION = PAGE)
ON FantasyPremierLeagueUserTeamPickStaging;
GO