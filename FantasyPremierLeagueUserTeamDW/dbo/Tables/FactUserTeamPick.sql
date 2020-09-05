CREATE TABLE dbo.FactUserTeamPick
(
	UserTeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKey INT NOT NULL,
	Position INT NOT NULL,
	Multiplier INT NOT NULL,
	IsCaptain BIT NOT NULL,
	IsViceCaptain BIT NOT NULL,	
	CONSTRAINT PK_FactUserTeamPick PRIMARY KEY CLUSTERED (UserTeamKey ASC, SeasonKey ASC, GameweekKey ASC, PlayerKey ASC)
)
GO