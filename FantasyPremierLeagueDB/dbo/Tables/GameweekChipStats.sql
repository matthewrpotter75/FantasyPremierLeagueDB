CREATE TABLE dbo.GameweekChipStats
(
	id int IDENTITY(1,1) NOT NULL,
	gameweekid int NOT NULL,
	chip_name varchar(100) NOT NULL,
	num_played int NOT NULL,
	CONSTRAINT PK_GameweekChipStats PRIMARY KEY CLUSTERED (id ASC)
)
GO

ALTER TABLE dbo.GameweekChipStats  WITH CHECK ADD  CONSTRAINT FK_GameweekChipStats_gameweekid FOREIGN KEY(gameweekid)
REFERENCES dbo.Gameweeks (id)
GO

ALTER TABLE dbo.GameweekChipStats CHECK CONSTRAINT FK_GameweekChipStats_gameweekid
GO


