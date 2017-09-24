CREATE TABLE dbo.PlayerPointsPerGamePrevious10
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
	CONSTRAINT [PK_PlayerPointsPerGamePrevious10] PRIMARY KEY CLUSTERED ([SeasonKey] ASC, [GameweekKey] ASC, [PlayerKey] ASC, [PlayerPositionKey] ASC, [OpponentDifficulty] ASC)
);