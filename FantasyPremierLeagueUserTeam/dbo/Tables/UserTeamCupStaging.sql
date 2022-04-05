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
	fromuserteamid INT NOT NULL,
	tiebreak VARCHAR(50) NULL,
	DateInserted SMALLDATETIME CONSTRAINT DF_UserTeamCupStaging_DateInserted DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT PK_UserTeamCupStaging PRIMARY KEY CLUSTERED (id ASC, fromuserteamid ASC, DateInserted ASC) ON FantasyPremierLeagueUserTeamStaging
)
ON FantasyPremierLeagueUserTeamStaging
GO


