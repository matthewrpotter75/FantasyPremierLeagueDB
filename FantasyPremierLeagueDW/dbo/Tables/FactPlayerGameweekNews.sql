CREATE TABLE [dbo].[FactPlayerGameweekNews]
(
	PlayerKey INT NOT NULL,
	TeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerNewsKey INT NOT NULL,
	FactPlayerGameweekStatusKey INT NOT NULL,
	CONSTRAINT PK_FactPlayerGameweekNews PRIMARY KEY CLUSTERED (PlayerKey ASC, SeasonKey ASC, GameweekKey ASC),
	CONSTRAINT FK_FactPlayerGameweekNews_PlayerKey FOREIGN KEY(PlayerKey) REFERENCES dbo.DimPlayer ([PlayerKey]),
	CONSTRAINT FK_FactPlayerGameweekNews_TeamKey FOREIGN KEY(TeamKey) REFERENCES dbo.DimTeam ([TeamKey]),
	CONSTRAINT FK_FactPlayerGameweekNews_SeasonKey FOREIGN KEY(SeasonKey) REFERENCES dbo.DimSeason ([SeasonKey]),
	CONSTRAINT FK_FactPlayerGameweekNews_GameweekKey FOREIGN KEY(GameweekKey, SeasonKey) REFERENCES dbo.DimGameweek ([GameweekKey], [SeasonKey]),
	CONSTRAINT FK_FactPlayerGameweekNews_FactPlayerGameweekStatusKey FOREIGN KEY(FactPlayerGameweekStatusKey) REFERENCES dbo.FactPlayerGameweekStatus (FactPlayerGameweekStatusKey),
	CONSTRAINT FK_FactPlayerGameweekNews_PlayerNewsKey FOREIGN KEY(PlayerNewsKey) REFERENCES dbo.DimPlayerNews ([PlayerNewsKey])
);