CREATE TABLE dbo.PossibleTeam
(
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKey INT NOT NULL,
	Cost INT NOT NULL,
	IsPlay BIT NOT NULL CONSTRAINT [DF_PossibleTeam_IsPlay] DEFAULT 0,
	IsCaptain BIT NOT NULL CONSTRAINT [DF_PossibleTeam_IsCaptain] DEFAULT 0,
	CONSTRAINT [PK_PossibleTeam] PRIMARY KEY CLUSTERED (SeasonKey ASC, GameweekKey ASC, PlayerKey ASC),
	CONSTRAINT [FK_PossibleTeam_PlayerKey] FOREIGN KEY (PlayerKey) REFERENCES [dbo].[DimPlayer] (PlayerKey),
	CONSTRAINT [FK_PossibleTeam_GameweekKey] FOREIGN KEY (GameweekKey, SeasonKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey)
);
GO

CREATE NONCLUSTERED INDEX [IX_PossibleTeam_PlayerKey] ON [dbo].[PossibleTeam] (PlayerKey);
GO