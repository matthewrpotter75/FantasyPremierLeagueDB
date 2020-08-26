CREATE TABLE dbo.FactUserTeamTransferHistory
(
	UserTeamKey INT NOT NULL,
	TransferTime SMALLDATETIME NOT NULL,
	PlayerIn INT NOT NULL,
	PlayerInCost INT NOT NULL,
	PlayerOut INT NOT NULL,
	PlayerOutCost INT NOT NULL,
	GameweekKey INT NOT NULL,
	CONSTRAINT PK_FactUserTeamTransferHistory PRIMARY KEY CLUSTERED (UserTeamKey ASC, GameweekKey ASC, PlayerIn ASC)
)
GO