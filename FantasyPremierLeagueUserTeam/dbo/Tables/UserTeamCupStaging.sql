CREATE TABLE dbo.UserTeamCupStaging
(
	id INT NOT NULL,
	homeTeam_userTeamid INT NOT NULL,
	homeTeam_userTeamName VARCHAR(200) NOT NULL,
	homeTeam_playerName VARCHAR(200) NOT NULL,
	awayTeam_userTeamid INT NOT NULL,
	awayTeam_userTeamName VARCHAR(200) NOT NULL,
	awayTeam_playerName VARCHAR(200) NOT NULL,
	is_knockout BIT NOT NULL,
	winner INT NULL,
	homeTeam_poINTs INT NOT NULL,
	homeTeam_win INT NOT NULL,
	homeTeam_draw INT NOT NULL,
	homeTeam_loss INT NOT NULL,
	awayTeam_poINTs INT NOT NULL,
	awayTeam_win INT NOT NULL,
	awayTeam_draw INT NOT NULL,
	awayTeam_loss INT NOT NULL,
	homeTeam_total INT NOT NULL,
	awayTeam_total INT NOT NULL,
	seed_value INT NULL,
	gameweekid INT NOT NULL,
	fromuserteamid INT NULL,
	tiebreak VARCHAR(50) NULL
)
GO


