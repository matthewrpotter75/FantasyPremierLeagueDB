CREATE TABLE dbo.FactUserTeamPickAutomaticSub
(
	UserTeamKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKeyIn INT NOT NULL,
	PlayerKeyOut INT NOT NULL,
	CONSTRAINT PK_FactUserTeamPickAutomaticSub PRIMARY KEY CLUSTERED (UserTeamKey ASC, GameweekKey ASC, PlayerKeyIn ASC)
)
GO