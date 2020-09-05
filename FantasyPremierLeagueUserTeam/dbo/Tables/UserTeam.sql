CREATE TABLE dbo.UserTeam
(
	id INT NOT NULL,
	player_first_name NVARCHAR(500) NULL,
	player_last_name NVARCHAR(500) NULL,
	player_region_id INT NULL,
	player_region_name VARCHAR(100) NULL,
	player_region_iso_code VARCHAR(3) NULL,
	summary_overall_points INT NOT NULL,
	summary_overall_rank INT NULL,
	summary_gameweek_points INT NOT NULL,
	summary_gameweek_rank INT NULL,
	current_gameweekId INT NOT NULL,
	joined_time SMALLDATETIME NOT NULL,
	team_name NVARCHAR(200) NOT NULL,
	team_bank INT NOT NULL,
	team_value INT NOT NULL,
	team_transfers INT NOT NULL,
	kit VARCHAR(500) NULL,
	favourite_teamid INT NULL,
	started_gameweekid INT NOT NULL,
	CONSTRAINT PK_UserTeam PRIMARY KEY CLUSTERED (id ASC)
	--CONSTRAINT FK_UserTeam_started_gameweekId FOREIGN KEY (started_gameweekId) REFERENCES dbo.Gameweeks (id),
	--CONSTRAINT FK_UserTeam_current_gameweek FOREIGN KEY (current_gameweekId) REFERENCES dbo.Gameweeks (id),
	--CONSTRAINT FK_UserTeam_favourite_teamId FOREIGN KEY (favourite_teamId) REFERENCES dbo.Teams (id)
);
GO