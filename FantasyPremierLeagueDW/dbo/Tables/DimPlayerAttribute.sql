CREATE TABLE [dbo].[DimPlayerAttribute]
(
	[PlayerAttributeKey] INT IDENTITY(1,1) NOT NULL,
	[PlayerKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[Influence] DECIMAL (6,2) NULL,
    [Creativity] DECIMAL (6,2) NULL,
    [Threat] DECIMAL (6,2) NULL,
    [ICT_Index] DECIMAL (6,2) NULL,
    [EA_Index] SMALLINT NOT NULL,
    [PlayerPositionKey] INT NOT NULL,
    [TeamKey] INT NOT NULL,
	CONSTRAINT [PK_DimPlayerAttribute] PRIMARY KEY CLUSTERED ([PlayerKey] ASC, [SeasonKey] ASC),
	CONSTRAINT [FK_DimPlayerAttribute_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_DimPlayerAttribute_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);