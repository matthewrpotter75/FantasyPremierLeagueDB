CREATE TABLE dbo.FactUserTeamChip
(
	UserTeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	ChipKey INT NOT NULL,
	ChipTime SMALLDATETIME NOT NULL,
	CONSTRAINT PK_FactUserTeamChip PRIMARY KEY CLUSTERED (UserTeamKey ASC, SeasonKey ASC, GameweekKey ASC, ChipKey ASC)
)
GO