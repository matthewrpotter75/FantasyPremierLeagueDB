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
	LastUpdated DATETIME NOT NULL CONSTRAINT [DF_PlayerPointsPerGamePrevious10_LastUpdated] DEFAULT 0,
	CONSTRAINT [PK_PlayerPointsPerGamePrevious10] PRIMARY KEY CLUSTERED ([SeasonKey] ASC, [GameweekKey] ASC, [PlayerKey] ASC, [PlayerPositionKey] ASC, [OpponentDifficulty] ASC),
	CONSTRAINT [FK_PlayerPointsPerGamePrevious10_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_PlayerPointsPerGamePrevious10_PlayerPositionKey] FOREIGN KEY ([PlayerPositionKey]) REFERENCES [dbo].[DimPlayerPosition] ([PlayerPositionKey]),
	CONSTRAINT [FK_PlayerPointsPerGamePrevious10_GameweekKey_SeasonKey] FOREIGN KEY ([GameweekKey], [SeasonKey]) REFERENCES [dbo].[DimGameweek] ([GameweekKey], [SeasonKey]),
	CONSTRAINT [FK_PlayerPointsPerGamePrevious10_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);