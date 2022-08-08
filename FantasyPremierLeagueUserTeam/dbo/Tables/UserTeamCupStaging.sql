CREATE TABLE dbo.UserTeamCupStaging
(
	id INT NOT NULL,
	homeTeam_userTeamid INT NULL,
	homeTeam_userTeamName VARCHAR(200) NOT NULL,
	homeTeam_playerName VARCHAR(200) NOT NULL,
	awayTeam_userTeamid INT NULL,
	awayTeam_userTeamName VARCHAR(200) NOT NULL,
	awayTeam_playerName VARCHAR(200) NOT NULL,
	is_knockout BIT NOT NULL,
	winner INT NULL,
	homeTeam_points INT NOT NULL,
	homeTeam_win INT NOT NULL,
	homeTeam_draw INT NOT NULL,
	homeTeam_loss INT NOT NULL,
	awayTeam_points INT NOT NULL,
	awayTeam_win INT NOT NULL,
	awayTeam_draw INT NOT NULL,
	awayTeam_loss INT NOT NULL,
	homeTeam_total INT NOT NULL,
	awayTeam_total INT NOT NULL,
	seed_value INT NULL,
	league INT NULL,
	gameweekid INT NOT NULL,
	fromuserteamid INT  NOT NULL,
	tiebreak VARCHAR(50) NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamCupStaging_DateInserted DEFAULT (getdate()) NOT NULL,
    CONSTRAINT PK_UserTeamCupStaging PRIMARY KEY CLUSTERED (id ASC, fromuserteamid ASC, DateInserted ASC) 
	WITH (DATA_COMPRESSION = PAGE) 
	ON FantasyPremierLeagueUserTeamStaging
)
ON FantasyPremierLeagueUserTeamStaging
GO

CREATE NONCLUSTERED INDEX IX_UserTeamCupStaging_DateInserted
    ON dbo.UserTeamCupStaging(DateInserted ASC)
    INCLUDE(homeTeam_userTeamid, homeTeam_userTeamName, homeTeam_playerName, awayTeam_userTeamid, awayTeam_userTeamName, awayTeam_playerName, is_knockout, winner, homeTeam_points, homeTeam_win, homeTeam_draw, homeTeam_loss, awayTeam_points, awayTeam_win, awayTeam_draw, awayTeam_loss, homeTeam_total, awayTeam_total, seed_value, league, gameweekid, tiebreak) 
	WITH (DATA_COMPRESSION = PAGE)
    ON FantasyPremierLeagueUserTeamStaging;
GO

CREATE NONCLUSTERED INDEX [IX_UserTeamCupStaging_winner]
    ON [dbo].[UserTeamCupStaging]([winner] ASC) WITH (DATA_COMPRESSION = PAGE)
    ON [FantasyPremierLeagueUserTeamStaging];
GO