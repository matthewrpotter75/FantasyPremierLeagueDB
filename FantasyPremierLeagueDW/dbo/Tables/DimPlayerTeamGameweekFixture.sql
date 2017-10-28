CREATE TABLE [dbo].[DimPlayerTeamGameweekFixture]
(
	PlayerKey INT NOT NULL,
	TeamKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekFixtureKey INT NOT NULL,
	IsHome BIT NOT NULL,
	CONSTRAINT [PK_DimPlayerTeamGameweekFixture] PRIMARY KEY CLUSTERED ([PlayerKey] ASC,[TeamKey] ASC,[GameweekKey] ASC,[SeasonKey] ASC, [GameweekFixtureKey] ASC),
	CONSTRAINT [FK_DimPlayerTeamGameweekFixture_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_DimPlayerTeamGameweekFixture_TeamKey] FOREIGN KEY ([TeamKey]) REFERENCES [dbo].[DimTeam] ([TeamKey]),
	CONSTRAINT [FK_DimPlayerTeamGameweekFixture_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey]),
	CONSTRAINT [FK_DimPlayerTeamGameweekFixture_GameweekFixtureKey] FOREIGN KEY([GameweekFixtureKey]) REFERENCES [dbo].[FactGameweekFixture] ([GameweekFixtureKey])
);
GO

CREATE NONCLUSTERED INDEX IX_DimPlayerTeamGameweekFixture_SeasonKey_GameweekFixtureKey_Inc_PlayerKey_TeamKey_GameweekKey_IsHome
ON [dbo].[DimPlayerTeamGameweekFixture] ([SeasonKey],[GameweekFixtureKey])
INCLUDE ([PlayerKey],[TeamKey],[GameweekKey],[IsHome])