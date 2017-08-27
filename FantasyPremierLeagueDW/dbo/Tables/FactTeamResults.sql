CREATE TABLE [dbo].[FactTeamResults]
(
	[FactTeamResultsKey] INT IDENTITY(1,1) NOT NULL,
	[GameweekFixtureKey] INT NOT NULL,
	[GameweekKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[TeamKey] INT NOT NULL,
	[OpponentTeamKey] INT NOT NULL,
	[IsHome] BIT NOT NULL,
	[GoalsFor] TINYINT NOT NULL,
	[GoalsAgainst] TINYINT NOT NULL,
	CONSTRAINT [PK_FactTeamResults] PRIMARY KEY CLUSTERED ([FactTeamResultsKey] ASC),
	CONSTRAINT [FK_FactTeamResults_GameweekKey_SeasonKey] FOREIGN KEY ([GameweekKey], [SeasonKey]) REFERENCES [dbo].[DimGameweek] ([GameweekKey], [SeasonKey]),
	CONSTRAINT [FK_FactTeamResults_GameweekFixtureKey] FOREIGN KEY ([GameweekFixtureKey]) REFERENCES [dbo].[FactGameweekFixture] ([GameweekFixtureKey]),
	CONSTRAINT [FK_FactTeamResults_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey]),
    CONSTRAINT [FK_FactTeamResults_OpponentTeamKey] FOREIGN KEY ([OpponentTeamKey]) REFERENCES [dbo].[DimTeam] ([TeamKey])
)