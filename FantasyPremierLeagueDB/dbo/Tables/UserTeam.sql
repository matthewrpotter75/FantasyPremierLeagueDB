CREATE TABLE dbo.UserTeam
(
	id INT NOT NULL,
	player_first_name VARCHAR(100) NOT NULL,
	player_last_name VARCHAR(100) NOT NULL,
	player_region_id INT NULL,
	player_region_name VARCHAR(100) NULL,
	player_region_short_iso VARCHAR(3) NULL,
	summary_overall_points INT NOT NULL,
	summary_overall_rank INT NOT NULL,
	summary_gameweek_points INT NOT NULL,
	summary_gameweek_rank INT NULL,
	joined_seconds INT NOT NULL,
	current_gameweekId INT NOT NULL,
	total_transfers INT NOT NULL,
	total_loans INT NOT NULL,
	total_loans_active INT NOT NULL,
	transfers_or_loans VARCHAR(10) NOT NULL,
	deleted BIT NOT NULL,
	email BIT NOT NULL,
	joined_time SMALLDATETIME NOT NULL,
	team_name VARCHAR(200) NOT NULL,
	team_bank INT NOT NULL,
	team_value INT NOT NULL,
	kit VARCHAR(500) NULL,
	gameweek_transfers INT NOT NULL,
	gameweek_transfers_cost INT NOT NULL,
	extra_free_transfers INT NOT NULL,
	strategy BIT NULL,
	favourite_teamId INT NULL,
	started_gameweekId INT NOT NULL,
	userPlayerid INT NOT NULL,
	CONSTRAINT PK_UserTeam PRIMARY KEY CLUSTERED (id ASC),
	CONSTRAINT FK_UserTeam_started_gameweekId FOREIGN KEY (started_gameweekId) REFERENCES dbo.Gameweeks (id),
	CONSTRAINT FK_UserTeam_current_gameweek FOREIGN KEY (current_gameweekId) REFERENCES dbo.Gameweeks (id),
	CONSTRAINT FK_UserTeam_favourite_teamId FOREIGN KEY (favourite_teamId) REFERENCES dbo.Teams (id)
);
GO

CREATE UNIQUE INDEX UX_UserTeams_userPlayerid ON dbo.UserTeam (userPlayerid);
GO