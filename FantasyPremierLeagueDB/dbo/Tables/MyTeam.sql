CREATE TABLE dbo.MyTeam
(
	PlayerId INT NOT NULL,
	PlayerPositionShortName VARCHAR(3),
	FirstName VARCHAR(50) NOT NULL,
	SecondName VARCHAR(50) NOT NULL,
	CONSTRAINT [PK_MyTeam] PRIMARY KEY CLUSTERED ([PlayerId] ASC),
	CONSTRAINT [FK_MyTeam_PlayerId] FOREIGN KEY ([PlayerId]) REFERENCES [dbo].[Players] ([id])
);
GO

CREATE NONCLUSTERED INDEX [IX_MyTeam_PlayerId] ON [dbo].[MyTeam] ([PlayerId]);
GO