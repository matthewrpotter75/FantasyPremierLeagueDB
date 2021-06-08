CREATE TABLE dbo.FactUserTeamSeasonHistory
(
	UserPlayerKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	TotalPoints INT NOT NULL,
	UserTeamRank INT NOT NULL,
	CONSTRAINT PK_FactUserTeamSeasonHistory PRIMARY KEY CLUSTERED (UserPlayerKey ASC, SeasonKey ASC)
)
GO