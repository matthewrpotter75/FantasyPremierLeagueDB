CREATE TABLE dbo.Cup
(
	id INT NOT NULL,
	homeTeam_userTeamid INT NOT NULL,
	homeTeam_userTeamName VARCHAR(100) NOT NULL,
	homeTeam_playerName VARCHAR(100) NOT NULL,
	awayTeam_userTeamid INT NOT NULL,
	awayTeam_userTeamName VARCHAR(100) NOT NULL,
	awayTeam_playerName VARCHAR(100) NOT NULL,
	is_knockout BIT NOT NULL,
	winner INT NULL,
	own_entry BIT NOT NULL,
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
	gameweekid INT NOT NULL
	CONSTRAINT PK_Cup PRIMARY KEY CLUSTERED (id ASC),
	CONSTRAINT FK_Cup_homeTeam_userTeamid FOREIGN KEY (homeTeam_userTeamid) REFERENCES dbo.UserTeam (id),
	CONSTRAINT FK_Cup_awayTeam_userTeamid FOREIGN KEY (awayTeam_userTeamid) REFERENCES dbo.UserTeam (id),
	CONSTRAINT FK_Cup_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id)
);
GO

CREATE INDEX IX_Cup_homeTeam_userteamid ON dbo.Cup (homeTeam_userTeamid);
GO

CREATE INDEX IX_Cup_awayTeam_userteamid ON dbo.Cup (awayTeam_userTeamid);
GO