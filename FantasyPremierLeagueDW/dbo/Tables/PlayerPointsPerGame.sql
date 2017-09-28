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
	CONSTRAINT [PK_PlayerPointsPerGame] PRIMARY KEY CLUSTERED ([PlayerKey] ASC, [PlayerPositionKey] ASC, [OpponentDifficulty] ASC, [MinutesLimit] ASC)
);