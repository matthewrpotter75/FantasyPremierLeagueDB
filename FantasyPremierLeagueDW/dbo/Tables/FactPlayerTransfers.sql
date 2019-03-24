CREATE TABLE dbo.FactPlayerTransfers
(
	PlayerTransfersKey INT IDENTITY(1,1) NOT NULL,
	UserTeamKey INT NOT NULL CONSTRAINT DF_FactPlayerTransfers_UserTeamKey  DEFAULT (1),
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerTransferredOutKey INT NOT NULL,
	PlayerTransferredInKey INT NOT NULL,
	PlayerTransferredOutCost INT NOT NULL,
	PlayerTransferredInCost INT NOT NULL,
	CONSTRAINT PK_FactPlayerTransfers PRIMARY KEY CLUSTERED (PlayerTransfersKey ASC),
	CONSTRAINT FK_FactPlayerTransfers_PlayerTransferredOutKey FOREIGN KEY (PlayerTransferredOutKey) REFERENCES dbo.DimPlayer (PlayerKey),
	CONSTRAINT FK_FactPlayerTransfers_PlayerTransferredInKey FOREIGN KEY (PlayerTransferredInKey) REFERENCES dbo.DimPlayer (PlayerKey),
	CONSTRAINT FK_FactPlayerTransfers_SeasonKey FOREIGN KEY (SeasonKey) REFERENCES dbo.DimSeason (SeasonKey),
	CONSTRAINT FK_FactPlayerTransfers_GameweekKey_SeasonKey FOREIGN KEY (GameweekKey,SeasonKey) REFERENCES dbo.DimGameweek (GameweekKey,SeasonKey),
	CONSTRAINT FK_FactPlayerTransfers_UserTeamKey_SeasonKey_GameweekKey_PlayerTransferredInKey FOREIGN KEY (UserTeamKey,SeasonKey,GameweekKey,PlayerTransferredInKey) REFERENCES dbo.DimUserTeamPlayer (UserTeamKey,SeasonKey,GameweekKey,PlayerKey)
);