CREATE TABLE dbo.UserTeamLeague
(
	id INT NOT NULL,
	league_name VARCHAR(100) NOT NULL,
	created SMALLDATETIME NOT NULL,
	closed BIT NOT NULL,
	league_rank INT NULL,
	league_size INT NULL,
	league_type CHAR(1) NOT NULL,
	scoring VARCHAR(2) NOT NULL,
	admin_userteamid INT NULL,
	start_gameweekid SMALLINT NOT NULL,
	code_privacy CHAR(1) NOT NULL,
	CONSTRAINT PK_UserTeamLeague PRIMARY KEY CLUSTERED (id ASC)
	--CONSTRAINT FK_UserTeamLeague_admin_userteamid FOREIGN KEY (admin_userteamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamLeague_start_gameweekid FOREIGN KEY (start_gameweekid) REFERENCES dbo.Gameweeks (id)
);