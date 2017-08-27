CREATE TABLE dbo.DimTeamGameweekFixture
(
	TeamKey INT NOT NULL,
	GameweekFixtureKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	OpponentTeamKey INT NOT NULL,
	IsHome BIT NOT NULL,
	KickoffTime SMALLDATETIME NOT NULL
	CONSTRAINT PK_DimTeamGameweekFixture PRIMARY KEY CLUSTERED (TeamKey ASC, GameweekFixtureKey ASC),
	CONSTRAINT FK_DimTeamGameweekFixture_SeasonKey FOREIGN KEY(SeasonKey) REFERENCES dbo.DimSeason ([SeasonKey]),
	CONSTRAINT FK_DimTeamGameweekFixture_TeamKey FOREIGN KEY(TeamKey) REFERENCES dbo.DimTeam ([TeamKey]),
	CONSTRAINT FK_DimTeamGameweekFixture_OpponentTeamKey FOREIGN KEY(OpponentTeamKey) REFERENCES dbo.DimTeam ([TeamKey]),
	CONSTRAINT FK_DimTeamGameweekFixture_GameweekKey_SeasonKey FOREIGN KEY(GameweekKey, SeasonKey) REFERENCES dbo.DimGameweek ([GameweekKey], [SeasonKey]),
	CONSTRAINT UX_DimTeamGameweekFixture_TeamKey_SeasonKey_GameweekKey_GameweekFixtureKey UNIQUE (TeamKey, SeasonKey, GameweekKey, GameweekFixtureKey)
);


