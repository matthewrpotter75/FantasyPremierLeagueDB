CREATE TABLE dbo.DimPlayerTeamSeason
(
	PlayerKey INT NOT NULL,
	TeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	DateInserted DATETIME NOT NULL,
	CONSTRAINT PK_DimPlayerTeamSeason PRIMARY KEY CLUSTERED (PlayerKey ASC,TeamKey ASC,SeasonKey ASC)
)
GO

ALTER TABLE dbo.DimPlayerTeamSeason ADD  CONSTRAINT DF_DimPlayerTeamSeason_DateInserted  DEFAULT (GETDATE()) FOR DateInserted
GO

ALTER TABLE dbo.DimPlayerTeamSeason  WITH NOCHECK ADD  CONSTRAINT FK_DimPlayerTeamSeason_PlayerKey FOREIGN KEY(PlayerKey)
REFERENCES dbo.DimPlayer (PlayerKey)
GO

ALTER TABLE dbo.DimPlayerTeamSeason CHECK CONSTRAINT FK_DimPlayerTeamSeason_PlayerKey
GO

ALTER TABLE dbo.DimPlayerTeamSeason  WITH NOCHECK ADD  CONSTRAINT FK_DimPlayerTeamSeason_SeasonKey FOREIGN KEY(SeasonKey)
REFERENCES dbo.DimSeason (SeasonKey)
GO

ALTER TABLE dbo.DimPlayerTeamSeason CHECK CONSTRAINT FK_DimPlayerTeamSeason_SeasonKey
GO

ALTER TABLE dbo.DimPlayerTeamSeason  WITH NOCHECK ADD  CONSTRAINT FK_DimPlayerTeamSeason_TeamKey FOREIGN KEY(TeamKey)
REFERENCES dbo.DimTeam (TeamKey)
GO

ALTER TABLE dbo.DimPlayerTeamSeason CHECK CONSTRAINT FK_DimPlayerTeamSeason_TeamKey
GO