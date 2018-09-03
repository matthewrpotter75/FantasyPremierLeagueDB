CREATE TABLE dbo.DimUserTeamPlayer
(
	UserTeamKey INT NOT NULL CONSTRAINT [DF_DimUserTeamPlayer_UserTeamKey] DEFAULT 1,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKey INT NOT NULL,
	Cost INT NULL,
	IsPlay BIT NOT NULL CONSTRAINT [DF_DimUserTeamPlayer_IsPlay] DEFAULT 0,
	IsCaptain BIT NOT NULL CONSTRAINT [DF_DimUserTeamPlayer_IsCaptain] DEFAULT 0,
	CONSTRAINT [PK_DimUserTeamPlayer] PRIMARY KEY CLUSTERED (UserTeamKey ASC, SeasonKey ASC, GameweekKey ASC, PlayerKey ASC),
	CONSTRAINT [FK_DimUserTeamPlayer_UserTeamKey] FOREIGN KEY (UserTeamKey) REFERENCES dbo.DimUserTeam (UserTeamKey),
	CONSTRAINT [FK_DimUserTeamPlayer_PlayerKey] FOREIGN KEY (PlayerKey) REFERENCES dbo.DimPlayer (PlayerKey),
	CONSTRAINT [FK_DimUserTeamPlayer_SeasonKey] FOREIGN KEY (SeasonKey) REFERENCES dbo.DimSeason (SeasonKey),
	CONSTRAINT [FK_DimUserTeamPlayer_GameweekKey] FOREIGN KEY (GameweekKey, SeasonKey) REFERENCES dbo.DimGameweek (GameweekKey, SeasonKey)
);
GO

CREATE NONCLUSTERED INDEX [IX_DimUserTeamPlayer_PlayerKey] ON dbo.DimUserTeamPlayer (PlayerKey);
GO