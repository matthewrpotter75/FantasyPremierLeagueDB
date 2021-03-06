﻿CREATE TABLE [dbo].[FactGameweekFixture]
(
	[GameweekFixtureKey] INT IDENTITY(1,1) NOT NULL,
	[GameweekKey] INT NULL,
	[SeasonKey] INT NOT NULL,
	[HomeTeamKey] INT NOT NULL,
	[AwayTeamKey] INT NOT NULL,
	[KickoffTime] SMALLDATETIME NULL,
    [HomeTeamScore] TINYINT NULL,
    [AwayTeamScore] TINYINT NULL,
	[IsScheduled] BIT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_FactGameweekFixture] PRIMARY KEY CLUSTERED ([GameweekFixtureKey] ASC),
	CONSTRAINT [FK_FactGameweekFixture_GameweekKey_SeasonKey] FOREIGN KEY ([GameweekKey], [SeasonKey]) REFERENCES [dbo].[DimGameweek] ([GameweekKey], [SeasonKey]),
	CONSTRAINT [FK_FactGameweekFixture_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);