CREATE TABLE dbo.DimUserTeamGameweekChip
(
	UserTeamKey INT NOT NULL,
	ChipKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	CONSTRAINT [PK_DimUserTeamGameweekChip] PRIMARY KEY CLUSTERED (UserTeamKey ASC, ChipKey ASC, SeasonKey ASC, GameweekKey ASC),
	CONSTRAINT [FK_DimUserTeamGameweekChip_UserTeamKey] FOREIGN KEY (UserTeamKey) REFERENCES dbo.DimUserTeam (UserTeamKey),
	CONSTRAINT [FK_DimUserTeamGameweekChip_ChipKey] FOREIGN KEY (ChipKey) REFERENCES dbo.DimChip (ChipKey),
	CONSTRAINT [FK_DimUserTeamGameweekChip_SeasonKey] FOREIGN KEY (SeasonKey) REFERENCES dbo.DimSeason (SeasonKey),
	CONSTRAINT [FK_DimUserTeamGameweekChip_ChipKey_SeasonKey] FOREIGN KEY (ChipKey, SeasonKey) REFERENCES dbo.DimChipSeason (ChipKey, SeasonKey),
);