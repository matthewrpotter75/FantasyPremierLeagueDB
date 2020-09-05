CREATE TABLE dbo.DimLeague
(
	LeagueKey INT IDENTITY(1,1) NOT NULL,
	LeagueName NVARCHAR(100) NOT NULL,
	Created SMALLDATETIME NOT NULL,
	MaxEntries INT NULL,
	LeagueType CHAR(1) NOT NULL,
	Scoring CHAR(1) NOT NULL,
	AdminUserteamKey INT NULL,
	StartGameweekKey INT NOT NULL,
	LeagueRank INT NULL,
	CodePrivacy CHAR(1) NOT NULL,
	LeagueId INT NOT NULL,
	SeasonKey INT NOT NULL,
	CONSTRAINT PK_DimLeague PRIMARY KEY CLUSTERED (LeagueKey ASC)
)
GO