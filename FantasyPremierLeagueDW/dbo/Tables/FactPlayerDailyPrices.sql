CREATE TABLE dbo.FactPlayerDailyPrices
(
	PlayerDailyPricesKey INT IDENTITY(1,1) NOT NULL,
	PlayerKey INT NOT NULL,
	TeamKey INT NOT NULL,
	DateKey INT NOT NULL,
	Cost TINYINT NOT NULL,
	CONSTRAINT PK_FactPlayerDailyPrices PRIMARY KEY CLUSTERED (PlayerDailyPricesKey ASC),
	CONSTRAINT FK_FactPlayerDailyPrices_PlayerKey FOREIGN KEY(PlayerKey) REFERENCES dbo.DimPlayer ([PlayerKey]),
	CONSTRAINT FK_FactPlayerDailyPrices_TeamKey FOREIGN KEY(TeamKey) REFERENCES dbo.DimTeam ([TeamKey]),
	CONSTRAINT FK_FactPlayerDailyPrices_DateKey FOREIGN KEY(DateKey) REFERENCES dbo.DimDate ([DateKey])
);