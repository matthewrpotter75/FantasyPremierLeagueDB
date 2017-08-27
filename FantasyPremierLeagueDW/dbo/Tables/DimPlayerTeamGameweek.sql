CREATE TABLE [dbo].[DimPlayerTeamGameweek]
(
	[PlayerKey] INT NOT NULL,
	[TeamKey] INT NOT NULL,
	[GameweekKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[IsHome] BIT NOT NULL,
	CONSTRAINT [PK_DimPlayerTeamGameweek] PRIMARY KEY CLUSTERED ([PlayerKey] ASC,[TeamKey] ASC,[GameweekKey] ASC,[SeasonKey] ASC),
	CONSTRAINT [FK_DimPlayerTeamGameweek_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_DimPlayerTeamGameweek_TeamKey] FOREIGN KEY ([TeamKey]) REFERENCES [dbo].[DimTeam] ([TeamKey]),
	CONSTRAINT [FK_DimPlayerTeamGameweek_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
)
