CREATE TABLE [dbo].[GameweekFixtures]
(
	[id] INT NOT NULL IDENTITY(1,1),
	[gameweekId] INT NULL,
	[homeTeamId] INT NOT NULL,
	[awayTeamId] INT NOT NULL,
	[homeTeam_Shortname] VARCHAR (3) NOT NULL,
	[awayTeam_Shortname] VARCHAR (3) NOT NULL,
	[kickoff_time] SMALLDATETIME NULL,
	IsScheduled BIT DEFAULT 1 NOT NULL,
	CONSTRAINT [PK_GameweekFixtures] PRIMARY KEY CLUSTERED ([homeTeamId] ASC, [awayTeamId] ASC),
	CONSTRAINT [FK_GameweekFixtures_gameweekId] FOREIGN KEY ([gameweekId]) REFERENCES [dbo].[Gameweeks] ([id]),
	CONSTRAINT [FK_GameweekFixtures_hometeamId] FOREIGN KEY ([homeTeamId]) REFERENCES [dbo].[Teams] ([id]),
	CONSTRAINT [FK_GameweekFixtures_awayteamId] FOREIGN KEY ([awayTeamId]) REFERENCES [dbo].[Teams] ([id])
);
GO

CREATE NONCLUSTERED INDEX [IX_GameweekFixtures_gameweekId] ON [dbo].[GameweekFixtures] ([gameweekId]);
GO

CREATE NONCLUSTERED INDEX [IX_GameweekFixtures_homeTeamId] ON [dbo].[GameweekFixtures] ([homeTeamId]);
GO

CREATE NONCLUSTERED INDEX [IX_GameweekFixtures_awayTeamId] ON [dbo].[GameweekFixtures] ([awayTeamId]);
GO