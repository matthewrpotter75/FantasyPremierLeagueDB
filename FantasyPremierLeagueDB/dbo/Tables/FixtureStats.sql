CREATE TABLE dbo.FixtureStats
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fixtureid] [int] NOT NULL,
	[identifier] [varchar](50) NOT NULL,
	CONSTRAINT [PK_FixtureStats] PRIMARY KEY CLUSTERED ([fixtureid] ASC,[id] ASC)
)
GO

ALTER TABLE [dbo].[FixtureStats]  WITH CHECK ADD  CONSTRAINT [FK_FixtureStats_fixtureid] FOREIGN KEY([fixtureid])
REFERENCES [dbo].[Fixture] ([id])
GO

ALTER TABLE [dbo].[FixtureStats] CHECK CONSTRAINT [FK_FixtureStats_fixtureid]
GO


