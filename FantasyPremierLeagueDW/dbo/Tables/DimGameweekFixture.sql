CREATE TABLE [dbo].[DimGameweekFixture]
(
	[GameweekFixtureId] INT IDENTITY(1,1) NOT NULL,
	[GameweekId] INT NOT NULL,
	[SeasonId] INT NOT NULL,
	[HomeTeamId] INT NOT NULL,
	[AwayTeamId] INT NOT NULL,
	[KickoffTime] SMALLDATETIME NOT NULL,
    [HomeTeamScore] TINYINT NULL,
    [AwayTeamScore] TINYINT NULL,
	CONSTRAINT [PK_DimGameweekFixture] PRIMARY KEY CLUSTERED ([GameweekFixtureId] ASC),
	CONSTRAINT [FK_DimGameweekFixture_GameweekId_SeasonId] FOREIGN KEY ([GameweekId], [SeasonId]) REFERENCES [dbo].[DimGameweek] ([GameweekId], [SeasonId]),
	CONSTRAINT [FK_DimGameweekFixture_SeasonId] FOREIGN KEY ([SeasonId]) REFERENCES [dbo].[DimSeason] ([SeasonId])
);