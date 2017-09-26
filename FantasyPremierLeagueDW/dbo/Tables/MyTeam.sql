CREATE TABLE dbo.MyTeam
(
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKey INT NOT NULL,
	IsPlay BIT NULL,
	CONSTRAINT [PK_MyTeam] PRIMARY KEY CLUSTERED (SeasonKey ASC, GameweekKey ASC, PlayerKey ASC),
	CONSTRAINT [FK_MyTeam_PlayerKey] FOREIGN KEY (PlayerKey) REFERENCES [dbo].[DimPlayer] (PlayerKey),
	CONSTRAINT [FK_MyTeam_GameweekKey] FOREIGN KEY (GameweekKey, SeasonKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey)
);
GO

CREATE NONCLUSTERED INDEX [IX_MyTeam_PlayerKey] ON [dbo].[MyTeam] (PlayerKey);
GO