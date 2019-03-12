CREATE TABLE dbo.PlayerPointsPerGame
(
	PlayerKey INT NOT NULL,
	PlayerPositionKey INT NOT NULL,
	OpponentDifficulty TINYINT NOT NULL,
	MinutesLimit INT NOT NULL,
	Points SMALLINT NOT NULL,
	Games TINYINT NOT NULL,
	PlayerMinutes SMALLINT NOT NULL,
	PPG DECIMAL(4,2) NOT NULL,
	LastUpdated DATETIME NOT NULL CONSTRAINT [DF_PlayerPointsPerGame_LastUpdated] DEFAULT 0,
	MinGameweekFixtureDatetime DATETIME NOT NULL CONSTRAINT [DF_PlayerPointsPerGame_MinGameweekFixtureDatetime] DEFAULT 0,
	MaxGameweekFixtureDatetime DATETIME NOT NULL CONSTRAINT [DF_PlayerPointsPerGame_MaxGameweekFixtureDatetime] DEFAULT 0,
	CONSTRAINT [PK_PlayerPointsPerGame] PRIMARY KEY CLUSTERED ([PlayerKey] ASC, [PlayerPositionKey] ASC, [OpponentDifficulty] ASC, [MinutesLimit] ASC),
	CONSTRAINT [FK_PlayerPointsPerGame_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_PlayerPointsPerGame_PlayerPositionKey] FOREIGN KEY ([PlayerPositionKey]) REFERENCES [dbo].[DimPlayerPosition] ([PlayerPositionKey])
);