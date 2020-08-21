CREATE TABLE dbo.PlayerHistoryPast
(
	id INT IDENTITY(1,1) NOT NULL,
	season_name VARCHAR(8) NOT NULL,
	element_code INT NOT NULL,
	start_cost TINYINT NOT NULL,
	end_cost TINYINT NOT NULL,
	total_points SMALLINT NOT NULL,
	[minutes] smallint NOT NULL,
	goals_scored TINYINT NOT NULL,
	assists TINYINT NOT NULL,
	clean_sheets TINYINT NOT NULL,
	goals_conceded TINYINT NOT NULL,
	own_goals TINYINT NOT NULL,
	penalties_saved TINYINT NOT NULL,
	penalties_missed TINYINT NOT NULL,
	yellow_cards TINYINT NOT NULL,
	red_cards TINYINT NOT NULL,
	saves TINYINT NOT NULL,
	bonus TINYINT NOT NULL,
	bps SMALLINT NOT NULL,
	influence DECIMAL(6, 2) NOT NULL,
	creativity DECIMAL(6, 2) NOT NULL,
	threat DECIMAL(6, 2) NOT NULL,
	ict_index DECIMAL(6, 2) NOT NULL,
	playerId INT NOT NULL,
	CONSTRAINT PK_HistoryPast PRIMARY KEY CLUSTERED (id ASC)
)
GO

ALTER TABLE dbo.PlayerHistoryPast  WITH CHECK ADD  CONSTRAINT FK_HistoryPast_playerId FOREIGN KEY(playerId)
REFERENCES dbo.Players (id)
GO

ALTER TABLE dbo.PlayerHistoryPast CHECK CONSTRAINT FK_HistoryPast_playerId
GO