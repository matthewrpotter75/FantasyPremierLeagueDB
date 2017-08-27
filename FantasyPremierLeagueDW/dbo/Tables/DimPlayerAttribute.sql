CREATE TABLE [dbo].[DimPlayerAttribute]
(
	[PlayerAttributeId] INT IDENTITY(1,1) NOT NULL,
	[PlayerKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[Influence] DECIMAL (6,2) NOT NULL,
    [Creativity] DECIMAL (6,2) NOT NULL,
    [Threat] DECIMAL (6,2) NOT NULL,
    [ICT_Index] DECIMAL (6,2) NOT NULL,
    [EA_Index] SMALLINT NOT NULL,
    [PlayerPositionKey] INT NOT NULL,
    [TeamKey] INT NOT NULL,
	CONSTRAINT [PK_DimPlayerAttribute] PRIMARY KEY CLUSTERED ([PlayerAttributeId] ASC),
	CONSTRAINT [FK_DimPlayerAttribute_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey])
);