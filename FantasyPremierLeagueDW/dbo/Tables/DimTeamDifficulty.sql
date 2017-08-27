CREATE TABLE [dbo].[DimTeamDifficulty]
(
	TeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	IsTeamHome BIT NOT NULL,
	IsOpponentHome BIT NOT NULL,
	Difficulty TINYINT NOT NULL,
	CONSTRAINT [PK_DimTeamDifficulty] PRIMARY KEY CLUSTERED (TeamKey ASC, SeasonKey ASC, [IsTeamHome] ASC),
	CONSTRAINT [FK_DimTeamDifficulty_TeamKey_SeasonKey] FOREIGN KEY (TeamKey, SeasonKey) REFERENCES [dbo].[DimTeamSeason] ([TeamKey], [SeasonKey]),
	CONSTRAINT [FK_DimTeamDifficulty_TeamKey] FOREIGN KEY (TeamKey) REFERENCES [dbo].[DimTeam] ([TeamKey]),
	CONSTRAINT [FK_DimTeamDifficulty_SeasonKey] FOREIGN KEY (SeasonKey) REFERENCES [dbo].[DimSeason] ([SeasonKey])
)
