CREATE TABLE dbo.DimLeagueType
(
	LeagueTypeKey INT NOT NULL,
	LeagueType CHAR(1) NOT NULL,
	CONSTRAINT PK_DimLeagueType PRIMARY KEY CLUSTERED (LeagueTypeKey ASC)
)
GO