CREATE TABLE [dbo].[Difficulty]
(
	[Id]				INT IDENTITY(1,1) NOT NULL,
	[teamId]			INT NOT NULL,
	[team_short_name]	VARCHAR(3) NOT NULL,
	[difficulty]		TINYINT NOT NULL,
	[is_home]			BIT NOT NULL,
	[is_opponent_home] BIT NOT NULL, 
    CONSTRAINT [PK_Difficulty] PRIMARY KEY CLUSTERED ([Id] ASC)
	--,CONSTRAINT [FK_Difficulty_teamId] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Teams] ([id])
)
