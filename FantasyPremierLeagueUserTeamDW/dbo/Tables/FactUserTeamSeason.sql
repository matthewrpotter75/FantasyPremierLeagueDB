CREATE TABLE dbo.FactUserTeamSeason
(
	UserTeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	TotalPoints INT NOT NULL,
	UserTeamRank INT NOT NULL,
	CONSTRAINT PK_FactUserTeamSeason PRIMARY KEY CLUSTERED (UserTeamKey ASC, SeasonKey ASC)
)
GO