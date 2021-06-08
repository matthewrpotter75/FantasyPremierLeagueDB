CREATE TABLE dbo.UserTeamCup
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
	gameweekid INT NOT NULL,
	fromuserteamid INT NOT NULL,
	tiebreak VARCHAR(50) NULL,
	CONSTRAINT PK_UserTeamCup PRIMARY KEY CLUSTERED ([id] ASC, [fromuserteamid] ASC)
	--CONSTRAINT FK_UserTeamCup_homeTeam_userTeamid FOREIGN KEY (homeTeam_userTeamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamCup_awayTeam_userTeamid FOREIGN KEY (awayTeam_userTeamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamCup_gameweekId FOREIGN KEY (gameweekid) REFERENCES dbo.Gameweeks (id)
);
GO

--CREATE INDEX IX_UserTeamCup_homeTeam_userteamid ON dbo.UserTeamCup (homeTeam_userTeamid);
--GO

--CREATE INDEX IX_UserTeamCup_awayTeam_userteamid ON dbo.UserTeamCup (awayTeam_userTeamid);
--GO