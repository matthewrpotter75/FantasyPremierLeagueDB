CREATE TABLE [dbo].[DimPlayerPosition]
(
	[PlayerPositionKey] INT NOT NULL,
    [SingularName] VARCHAR (16) NOT NULL,
    [SingularNameShort] VARCHAR (3) NOT NULL,
    [PluralName] VARCHAR (16) NOT NULL,
    [PluralNameShort] VARCHAR (3) NOT NULL,
	CONSTRAINT [PK_DimPlayerPosition] PRIMARY KEY CLUSTERED ([PlayerPositionKey] ASC)
);