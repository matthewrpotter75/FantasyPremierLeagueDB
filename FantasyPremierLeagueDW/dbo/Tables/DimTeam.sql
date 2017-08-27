CREATE TABLE [dbo].[DimTeam]
(
	[TeamKey] INT IDENTITY(1,1) NOT NULL,
    [TeamName] VARCHAR (50) NOT NULL,
    [TeamCode] INT NOT NULL,
    [TeamShortName] VARCHAR (3) NOT NULL,
	CONSTRAINT [PK_DimTeam] PRIMARY KEY CLUSTERED ([TeamKey] ASC)
)
