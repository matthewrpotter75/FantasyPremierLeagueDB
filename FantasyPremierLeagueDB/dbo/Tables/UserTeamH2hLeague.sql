CREATE TABLE dbo.UserTeamH2hLeague
(
	id INT NOT NULL,
	entry_rank INT NULL,
	entry_last_rank INT NULL,
	entry_movement VARCHAR(10) NULL,
	entry_change INT NULL,
	entry_can_leave BIT NOT NULL,
	entry_can_admin BIT NOT NULL,
	entry_can_invite BIT NOT NULL,
	entry_can_forum BIT NOT NULL,
	entry_code VARCHAR(20) NULL,
	league_name VARCHAR(100) NOT NULL,
	is_cup BIT NOT NULL,
	short_name VARCHAR(50) NULL,
	created SMALLDATETIME NOT NULL,
	closed BIT NOT NULL,
	forum_disabled BIT NOT NULL,
	make_code_public BIT NOT NULL,
	league_rank INT NULL,
	league_size INT NULL,
	league_type CHAR(1) NOT NULL,
	scoring CHAR(1) NOT NULL,
	ko_rounds INT NOT NULL,
	admin_userTeamid INT NULL,
	start_gameweekid INT NOT NULL,
	userTeamid INT NOT NULL,
	CONSTRAINT PK_UserTeamH2hLeague PRIMARY KEY CLUSTERED (userTeamid ASC, id ASC)
	--CONSTRAINT FK_UserTeamH2hLeague_userTeamid FOREIGN KEY (userTeamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamH2hLeague_admin_userTeamid FOREIGN KEY (admin_userTeamid) REFERENCES dbo.UserTeam (id),
	--CONSTRAINT FK_UserTeamH2hLeague_start_gameweekid FOREIGN KEY (start_gameweekid) REFERENCES dbo.Gameweeks (id)
);