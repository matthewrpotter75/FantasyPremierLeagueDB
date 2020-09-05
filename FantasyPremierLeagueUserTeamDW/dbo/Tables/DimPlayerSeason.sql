CREATE TABLE [dbo].[DimPlayerSeason]
(
	[PlayerKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[PlayerId] INT NULL,
	[DateInserted] DATETIME CONSTRAINT [DF_DimPlayerSeason_DateInserted] DEFAULT (GETDATE()) NOT NULL,
	CONSTRAINT [PK_DimPlayerSeason] PRIMARY KEY CLUSTERED ([PlayerKey] ASC, [SeasonKey] ASC),
	CONSTRAINT [FK_DimPlayerSeason_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_DimPlayerSeason_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);