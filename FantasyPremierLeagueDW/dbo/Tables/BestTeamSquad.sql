CREATE TABLE dbo.BestTeamSquad
(
	SeasonKey INT NOT NULL,
	GameweekStart INT NOT NULL,
	GameweekEnd INT NOT NULL,
	PlayerKey INT NOT NULL,
	PlayerPositionKey INT NOT NULL,
	Cost INT NOT NULL,
	TotalPoints INT NOT NULL,
	IsPlay BIT NULL,
	IsCaptain BIT NULL,
	CONSTRAINT [PK_BestTeamSquad] PRIMARY KEY CLUSTERED (SeasonKey ASC, GameweekStart ASC, GameweekEnd ASC, PlayerPositionKey ASC, PlayerKey ASC),
	CONSTRAINT [FK_BestTeamSquad_PlayerKey] FOREIGN KEY (PlayerKey) REFERENCES [dbo].[DimPlayer] (PlayerKey),
	CONSTRAINT [FK_BestTeamSquad_PlayerPositionKey] FOREIGN KEY (PlayerPositionKey) REFERENCES [dbo].[DimPlayerPosition] (PlayerPositionKey),
	CONSTRAINT [FK_BestTeamSquad_GameweekStart] FOREIGN KEY (GameweekStart, SeasonKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey),
	CONSTRAINT [FK_BestTeamSquad_GameweekEnd] FOREIGN KEY (GameweekEnd, SeasonKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey)
);
GO

CREATE NONCLUSTERED INDEX [IX_BestTeamSquad_PlayerKey] ON [dbo].[BestTeamSquad] (PlayerKey);
GO