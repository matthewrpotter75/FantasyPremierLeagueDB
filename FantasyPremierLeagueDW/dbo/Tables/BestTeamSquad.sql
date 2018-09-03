CREATE TABLE dbo.BestTeamSquad
(
	SeasonStartKey INT NOT NULL,
	SeasonEndKey INT NOT NULL,
	GameweekStart INT NOT NULL,
	GameweekEnd INT NOT NULL,
	PlayerKey INT NOT NULL,
	PlayerPositionKey INT NOT NULL,
	Cost INT NOT NULL,
	TotalPoints INT NOT NULL,
	IsPlay BIT NULL,
	IsCaptain BIT NULL,
	CONSTRAINT [PK_BestTeamSquad] PRIMARY KEY CLUSTERED (SeasonStartKey ASC, SeasonEndKey ASC, GameweekStart ASC, GameweekEnd ASC, PlayerPositionKey ASC, PlayerKey ASC),
	CONSTRAINT [FK_BestTeamSquad_PlayerKey] FOREIGN KEY (PlayerKey) REFERENCES [dbo].[DimPlayer] (PlayerKey),
	CONSTRAINT [FK_BestTeamSquad_PlayerPositionKey] FOREIGN KEY (PlayerPositionKey) REFERENCES [dbo].[DimPlayerPosition] (PlayerPositionKey),
	CONSTRAINT [FK_BestTeamSquad_GameweekStart] FOREIGN KEY (GameweekStart, SeasonStartKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey),
	CONSTRAINT [FK_BestTeamSquad_GameweekEnd] FOREIGN KEY (GameweekEnd, SeasonEndKey) REFERENCES [dbo].[DimGameweek] (GameweekKey, SeasonKey),
	CONSTRAINT [FK_BestTeamSquad_SeasonStartKey] FOREIGN KEY([SeasonStartKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey]),
	CONSTRAINT [FK_BestTeamSquad_SeasonEndKey] FOREIGN KEY([SeasonEndKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);
GO

CREATE NONCLUSTERED INDEX [IX_BestTeamSquad_PlayerKey] ON [dbo].[BestTeamSquad] (PlayerKey);
GO