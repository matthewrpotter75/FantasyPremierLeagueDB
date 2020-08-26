CREATE TABLE dbo.FactUserTeamGameweekHistory
(
	UserTeamKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	Points INT NOT NULL,
	TotalPoints INT NOT NULL,
	[Rank] INT NULL,
	RankSort INT NULL,
	OverallRank INT NULL,
	GameweekTransfers INT NOT NULL,
	GameweekTransfersCost INT NOT NULL,
	TeamBank INT NOT NULL,
	TeamValue INT NOT NULL,
	PointsOnBench INT NOT NULL,
	CONSTRAINT PK_FactUserTeamGameweekHistory PRIMARY KEY CLUSTERED (UserTeamKey ASC, GameweekKey ASC)
)
GO