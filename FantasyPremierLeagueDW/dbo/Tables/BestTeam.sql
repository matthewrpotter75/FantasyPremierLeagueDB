CREATE TABLE dbo.BestTeam
(
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKey INT NOT NULL,
	PlayerPositionKey INT NOT NULL,
	Cost INT NOT NULL,
	TotalPoints INT NOT NULL,
	IsPlay BIT NOT NULL CONSTRAINT [DF_BestTeam_IsPlay] DEFAULT 0,
	IsCaptain BIT NOT NULL CONSTRAINT [DF_BestTeam_IsCaptain] DEFAULT 0,
	CONSTRAINT [PK_BestTeam] PRIMARY KEY CLUSTERED (SeasonKey ASC, GameweekKey ASC, PlayerPositionKey ASC, PlayerKey ASC),
	CONSTRAINT [FK_BestTeam_PlayerKey] FOREIGN KEY (PlayerKey) REFERENCES [dbo].[DimPlayer] (PlayerKey),
	CONSTRAINT [FK_BestTeam_PlayerPositionKey] FOREIGN KEY (PlayerPositionKey) REFERENCES [dbo].[DimPlayerPosition] (PlayerPositionKey),
	CONSTRAINT [FK_BestTeam_GameweekKey] FOREIGN KEY (GameweekKey, SeasonKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey)
);
GO


CREATE NONCLUSTERED INDEX [IX_BestTeam_PlayerKey] ON [dbo].[BestTeam] (PlayerKey);
GO