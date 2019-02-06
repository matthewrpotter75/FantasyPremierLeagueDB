CREATE TABLE [dbo].[DimPlayer] (
    [PlayerKey]  INT           IDENTITY (1, 1) NOT NULL,
    [FirstName]  VARCHAR (50)  NOT NULL,
    [SecondName] VARCHAR (50)  NOT NULL,
    [WebName]    VARCHAR (100) NOT NULL,
    [PlayerName] VARCHAR (100) NOT NULL,
	[LatestPlayerId] INT NULL,
	[LatestTeamId] INT NULL,
	[DateInserted] DATETIME NULL CONSTRAINT [DF_DimPlayer_DateInserted] DEFAULT GETDATE(),
    CONSTRAINT [PK_DimPlayer] PRIMARY KEY CLUSTERED ([PlayerKey] ASC)
);

