CREATE TABLE dbo.FactUserTeamPickAutomaticSub
(
	UserTeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerIn INT NOT NULL,
	PlayerOut INT NOT NULL,
	CONSTRAINT PK_FactUserTeamPickAutomaticSub PRIMARY KEY CLUSTERED (UserTeamKey ASC, SeasonKey ASC, GameweekKey ASC, PlayerIn ASC)
)
GO