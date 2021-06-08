CREATE TABLE dbo.UserTeamUpdateStaging
(
	id INT NOT NULL,
	player_first_name NVARCHAR(100) NULL,
	player_last_name NVARCHAR(100) NULL,
	player_region_id INT NULL,
	player_region_name VARCHAR(100) NULL,
	player_region_iso_code VARCHAR(3) NULL,
	summary_overall_points INT NULL,
	summary_overall_rank INT NULL,
	summary_gameweek_points INT NULL,
	summary_gameweek_rank INT NULL,
	current_gameweekId INT NULL,
	joined_time SMALLDATETIME NOT NULL,
	team_name NVARCHAR(40) NULL,
	team_bank INT NULL,
	team_value INT NULL,
	team_transfers INT NULL,
	kit VARCHAR(500) NULL,
	favourite_teamid INT NULL,
	started_gameweekid INT NOT NULL,
	DateInserted DATETIME CONSTRAINT DF_UserTeamUpdateStaging_DateInserted DEFAULT (getdate()) NULL
	--CONSTRAINT PK_UserTeamUpdateStaging PRIMARY KEY CLUSTERED (id ASC)
)
GO