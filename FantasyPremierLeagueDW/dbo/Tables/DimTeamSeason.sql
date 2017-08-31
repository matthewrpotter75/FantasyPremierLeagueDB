CREATE TABLE [dbo].[DimTeamSeason]
(
	[TeamKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[TeamId] INT NULL,
	CONSTRAINT [PK_DimTeamSeason] PRIMARY KEY CLUSTERED ([TeamKey] ASC, [SeasonKey] ASC),
	CONSTRAINT [FK_DimTeamSeason_TeamKey] FOREIGN KEY ([TeamKey]) REFERENCES [dbo].[DimTeam] ([TeamKey]),
	CONSTRAINT [FK_DimTeamSeason_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
)
