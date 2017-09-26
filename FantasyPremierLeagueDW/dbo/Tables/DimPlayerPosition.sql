CREATE TABLE [dbo].[DimPlayerPosition]
(
	[PlayerPositionKey] INT NOT NULL,
    PlayerPosition VARCHAR (16) NOT NULL,
    PlayerPositionShort VARCHAR (3) NOT NULL,
    PlayerPositionPlural VARCHAR (16) NOT NULL,
    PlayerPositionPluralShort VARCHAR (3) NOT NULL,
	CONSTRAINT [PK_DimPlayerPosition] PRIMARY KEY CLUSTERED ([PlayerPositionKey] ASC)
);