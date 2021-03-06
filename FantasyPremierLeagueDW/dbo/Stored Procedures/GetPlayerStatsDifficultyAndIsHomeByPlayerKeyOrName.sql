CREATE PROCEDURE dbo.GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrName
(
	@PlayerKey INT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@SecondName VARCHAR(50) = NULL,
	@PlayerName VARCHAR(50) = NULL,
	@MinutesLimit INT = 30,
	@SeasonKey INT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @PlayerKey IS NULL
	BEGIN

		SELECT @PlayerKey = PlayerKey
		FROM dbo.DimPlayer
		WHERE FirstName = @FirstName AND SecondName = @SecondName;

		IF @PlayerKey IS NULL
		BEGIN

			SELECT TOP 1 @PlayerKey = PlayerKey
			FROM dbo.DimPlayer
			WHERE SecondName = @SecondName;

		END

		IF @PlayerKey IS NULL
		BEGIN

			SELECT TOP 1 @PlayerKey = PlayerKey
			FROM dbo.DimPlayer
			WHERE PlayerName = @PlayerName;

		END

	END

	SELECT PlayerKey, PlayerName
	FROM dbo.DimPlayer
	WHERE PlayerKey = @PlayerKey;

	SELECT 'Points average for all seasons - all games';

	SELECT SUM(ph.TotalPoints) AS TotalPoints,
	COUNT(ph.PlayerHistoryKey) AS TotalGames,
	CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(ph.PlayerHistoryKey) AS DECIMAL(5,2)) AS AvgPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer dp
	ON ph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.WasHome = td.IsOpponentHome
	AND ph.SeasonKey = td.SeasonKey
	WHERE ph.PlayerKey = @PlayerKey
	AND ph.[Minutes] >= @MinutesLimit;

	SELECT 'Points average for specified season - all games';

	SELECT SUM(ph.TotalPoints) AS TotalPoints,
	COUNT(ph.PlayerHistoryKey) AS TotalGames,
	CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(ph.PlayerHistoryKey) AS DECIMAL(5,2)) AS AvgPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer dp
	ON ph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.WasHome = td.IsOpponentHome
	AND ph.SeasonKey = td.SeasonKey
	WHERE ph.PlayerKey = @PlayerKey
	AND ph.SeasonKey = @SeasonKey
	AND ph.[Minutes] >= @MinutesLimit;

	SELECT 'Points average for specified season by Difficulty and WasHome';
	
	--Points average for specified season by Difficulty and WasHome
	SELECT td.Difficulty,
	ph.WasHome,
	SUM(ph.TotalPoints) AS TotalPoints,
	COUNT(ph.PlayerHistoryKey) AS TotalGames,
	CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(ph.PlayerHistoryKey) AS DECIMAL(5,2)) AS AvgPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer dp
	ON ph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.WasHome = td.IsOpponentHome
	AND ph.SeasonKey = td.SeasonKey
	WHERE ph.PlayerKey = @PlayerKey
	AND ph.SeasonKey = @SeasonKey
	AND ph.[Minutes] >= @MinutesLimit
	GROUP BY td.Difficulty, ph.WasHome
	ORDER BY td.Difficulty, ph.WasHome;

	SELECT 'Points average for all seasons by Difficulty and WasHome';
	
	--Points average for all seasons by Difficulty and WasHome
	SELECT td.Difficulty,
	ph.WasHome,
	SUM(ph.TotalPoints) AS TotalPoints,
	COUNT(ph.PlayerHistoryKey) AS TotalGames,
	CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(ph.PlayerHistoryKey) AS DECIMAL(5,2)) AS AvgPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer dp
	ON ph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.WasHome = td.IsOpponentHome
	AND ph.SeasonKey = td.SeasonKey
	WHERE ph.PlayerKey = @PlayerKey
	AND ph.[Minutes] >= @MinutesLimit
	GROUP BY td.Difficulty, ph.WasHome
	ORDER BY td.Difficulty, ph.WasHome;

	SELECT 'Points average for specified season by Difficulty';
	
	--Points average for all seasons by Difficulty
	SELECT td.Difficulty,
	SUM(ph.TotalPoints) AS TotalPoints,
	COUNT(ph.PlayerHistoryKey) AS TotalGames,
	CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(ph.PlayerHistoryKey) AS DECIMAL(5,2)) AS AvgPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer dp
	ON ph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.WasHome = td.IsOpponentHome
	AND ph.SeasonKey = td.SeasonKey
	WHERE ph.PlayerKey = @PlayerKey
	AND ph.SeasonKey = @SeasonKey
	AND ph.[Minutes] >= @MinutesLimit
	GROUP BY td.Difficulty
	ORDER BY td.Difficulty;

	SELECT 'Points average for all seasons by Difficulty';
	
	--Points average for all seasons by Difficulty
	SELECT td.Difficulty,
	SUM(ph.TotalPoints) AS TotalPoints,
	COUNT(ph.PlayerHistoryKey) AS TotalGames,
	CAST((SUM(ph.TotalPoints) * 1.00)/COUNT(ph.PlayerHistoryKey) AS DECIMAL(5,2)) AS AvgPoints
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayer dp
	ON ph.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimTeamDifficulty td
	ON ph.OpponentTeamKey = td.TeamKey
	AND ph.WasHome = td.IsOpponentHome
	AND ph.SeasonKey = td.SeasonKey
	WHERE ph.PlayerKey = @PlayerKey
	AND ph.[Minutes] >= @MinutesLimit
	GROUP BY td.Difficulty
	ORDER BY td.Difficulty;

END