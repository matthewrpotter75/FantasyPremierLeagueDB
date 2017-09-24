CREATE TABLE dbo.PlayerPointsPerGamePrevious5
(
	PlayerKey INT NOT NULL,
	PlayerPositionKey INT NOT NULL,
	OpponentDifficulty TINYINT NOT NULL,
	SeasonKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	MinutesLimit INT NOT NULL,
	Points SMALLINT NOT NULL,
	Games TINYINT NOT NULL,
	PlayerMinutes SMALLINT NOT NULL,
	PPG DECIMAL(4,2) NOT NULL,
	PPG5games DECIMAL(4,2),
	PPG10games DECIMAL(4,2),
	CONSTRAINT [PK_PlayerPointsPerGamePrevious5] PRIMARY KEY CLUSTERED ([SeasonKey] ASC, [GameweekKey] ASC, [PlayerKey] ASC, [PlayerPositionKey] ASC, [OpponentDifficulty] ASC)
);