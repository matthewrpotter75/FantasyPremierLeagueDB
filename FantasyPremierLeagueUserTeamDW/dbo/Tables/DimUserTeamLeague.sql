CREATE TABLE dbo.DimUserTeamLeague
(
	UserTeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	LeagueKey INT NOT NULL,
	[Rank] INT NULL,
	LastRank INT NULL,
	UserCanLeave BIT NOT NULL,
	IsAdmin BIT NOT NULL,
	CanInvite BIT NOT NULL,
	CONSTRAINT PK_DimUserTeamLeague PRIMARY KEY CLUSTERED (UserTeamKey ASC, SeasonKey ASC, LeagueKey ASC)
)
GO