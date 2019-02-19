CREATE TABLE [dbo].[FactPlayerGameweekStatus]
(
	FactPlayerGameweekStatusKey INT IDENTITY(1,1) NOT NULL,
	PlayerKey INT NOT NULL,
	TeamKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerStatus CHAR(1) NOT NULL,
	Cost TINYINT NOT NULL,
	ChanceOfPlayingThisRound DECIMAL(5,2) NULL,
	ChanceOfPlayingNextRound DECIMAL(5,2) NULL,
    SelectedByPercent DECIMAL(6,2) NOT NULL,
    Form DECIMAL(6,2) NULL,
    TransfersOut INT NOT NULL,
    TransfersIn INT NOT NULL,
    TransfersOutEvent INT NOT NULL,
    TransfersInEvent INT NOT NULL,
    TotalPoints SMALLINT NOT NULL,
    EventPoints SMALLINT NOT NULL,
    PointsPerGame DECIMAL(4,2) NOT NULL,
    ExpectedPointsThis DECIMAL(4,2) NULL,
    ExpectedPointsNext DECIMAL(4,2) NULL,
	CONSTRAINT PK_FactPlayerGameweekStatus PRIMARY KEY CLUSTERED (FactPlayerGameweekStatusKey ASC),
	CONSTRAINT FK_FactPlayerGameweekStatus_PlayerKey FOREIGN KEY(PlayerKey) REFERENCES dbo.DimPlayer ([PlayerKey]),
	CONSTRAINT FK_FactPlayerGameweekStatus_TeamKey FOREIGN KEY(TeamKey) REFERENCES dbo.DimTeam ([TeamKey]),
	CONSTRAINT FK_FactPlayerGameweekStatus_SeasonKey FOREIGN KEY(SeasonKey) REFERENCES dbo.DimSeason ([SeasonKey]),
	CONSTRAINT FK_FactPlayerGameweekStatus_GameweekKey FOREIGN KEY(GameweekKey, SeasonKey) REFERENCES dbo.DimGameweek ([GameweekKey], [SeasonKey]),
	CONSTRAINT UX_FactPlayerGameweekStatus_PlayerKey_SeasonKey_GameweekKey UNIQUE (PlayerKey, SeasonKey, GameweekKey)
);
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerGameweekStatus_SeasonKey_GameweekKey
ON [dbo].[FactPlayerGameweekStatus] ([SeasonKey],[GameweekKey])
INCLUDE ([PlayerKey],[Cost])
GO