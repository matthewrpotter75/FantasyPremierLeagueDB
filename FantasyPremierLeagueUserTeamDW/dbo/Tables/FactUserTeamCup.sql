CREATE TABLE dbo.FactUserTeamCup
(
	GameweekKey INT NOT NULL,
	HomeTeamUserTeamKey INT NOT NULL,
	AwayTeamUserTeamKey INT NOT NULL,
	IsKnockout BIT NOT NULL,
	Winner INT NULL,
	CONSTRAINT PK_FactUserTeamCup PRIMARY KEY CLUSTERED (GameweekKey ASC, HomeTeamUserTeamKey ASC, AwayTeamUserTeamKey ASC)
)
GO