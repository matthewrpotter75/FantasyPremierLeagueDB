CREATE TABLE dbo.DimUserTeam
(
	UserTeamKey INT NOT NULL,
	UserKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	UserTeamName VARCHAR(100) NOT NULL,
	UserTeamDescription VARCHAR(100) NULL
	CONSTRAINT [PK_DimUserTeam] PRIMARY KEY CLUSTERED (UserTeamKey ASC),
	CONSTRAINT [FK_DimUserTeam_UserKey] FOREIGN KEY (UserKey) REFERENCES dbo.DimUser (UserKey),
	CONSTRAINT [FK_DimUserTeam_SeasonKey] FOREIGN KEY (SeasonKey) REFERENCES dbo.DimSeason (SeasonKey)
);