DECLARE @SeasonKey INT, @GameweekKey INT, @i INT = 6, @MaxId INT;

--Populate PlayerPointsPerGame
MERGE INTO dbo.PlayerPointsPerGame AS Target 
USING 
(
	SELECT PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
	FROM dbo.fnGetPPGByPlayerPlayerPositionDificulty(12, 1, 30)

	UNION

	SELECT PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
	FROM dbo.fnGetPPGByPlayerPlayerPositionDificulty(12, 2, 30)

	UNION

	SELECT PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
	FROM dbo.fnGetPPGByPlayerPlayerPositionDificulty(12, 3, 30)

	UNION

	SELECT PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
	FROM dbo.fnGetPPGByPlayerPlayerPositionDificulty(12, 4, 30)
)
AS Source (PlayerKey, PlayerPositionKey, OpponentDifficulty, MinutesLimit, Points, Games, PlayerMinutes, PPG)
ON Target.PlayerKey = Source.PlayerKey
AND Target.PlayerPositionKey = Source.PlayerPositionKey
AND Target.OpponentDifficulty = Source.OpponentDifficulty
AND Target.MinutesLimit = Source.MinutesLimit
WHEN MATCHED THEN 
UPDATE SET Points = Source.Points,
Games = Source.Games,
PlayerMinutes = Source.PlayerMinutes,
PPG = Source.PPG
WHEN NOT MATCHED BY TARGET THEN 
INSERT (PlayerKey, PlayerPositionKey, OpponentDifficulty, MinutesLimit, Points, Games, PlayerMinutes, PPG) 
VALUES (Source.PlayerKey, Source.PlayerPositionKey, Source.OpponentDifficulty, Source.MinutesLimit, Source.Points, Source.Games, Source.PlayerMinutes, Source.PPG);

--Populate PlayerPointsPerGamePrevious5 and PlayerPointsPerGamePrevious10
CREATE TABLE #SeasonGameweeks (Id INT IDENTITY(1,1), SeasonKey INT, GameweekKey INT)

INSERT INTO #SeasonGameweeks
(SeasonKey, GameweekKey)
SELECT SeasonKey, GameweekKey
FROM dbo.FactPlayerHistory
GROUP BY SeasonKey, GameweekKey
ORDER BY SeasonKey, GameweekKey;

SELECT @i;

SELECT @MaxId = MAX(Id) FROM #SeasonGameweeks;
SELECT @MaxId AS MaxId;

WHILE @i <= @MaxId
BEGIN

	SELECT @SeasonKey = SeasonKey, @GameweekKey = GameweekKey
	FROM #SeasonGameweeks
	WHERE Id = @i;

	MERGE INTO dbo.PlayerPointsPerGamePrevious5 AS Target 
	USING 
	(
		SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
		FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 1, 30, 5)

		UNION

		SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
		FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 2, 30, 5)

		UNION

		SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
		FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 3, 30, 5)

		UNION

		SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
		FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 4, 30, 5)
	)
	AS Source (SeasonKey, GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, MinutesLimit, Points, Games, PlayerMinutes, PPG)
	ON Target.SeasonKey = Source.SeasonKey
	AND Target.GameweekKey = Source.GameweekKey
	AND Target.PlayerKey = Source.PlayerKey
	AND Target.PlayerPositionKey = Source.PlayerPositionKey
	AND Target.OpponentDifficulty = Source.OpponentDifficulty
	AND Target.MinutesLimit = Source.MinutesLimit
	WHEN MATCHED THEN 
	UPDATE SET Points = Source.Points,
	Games = Source.Games,
	PlayerMinutes = Source.PlayerMinutes,
	PPG = Source.PPG
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT (SeasonKey, GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, MinutesLimit, Points, Games, PlayerMinutes, PPG)
	VALUES (Source.SeasonKey, Source.GameweekKey, Source.PlayerKey, Source.PlayerPositionKey, Source.OpponentDifficulty, Source.MinutesLimit, Source.Points, Source.Games, Source.PlayerMinutes, Source.PPG);

	
	IF @i > 10
	BEGIN

		MERGE INTO dbo.PlayerPointsPerGamePrevious10 AS Target 
		USING 
		(
			SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
			FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 1, 30, 10)

			UNION

			SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
			FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 2, 30, 10)

			UNION

			SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
			FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 3, 30, 10)

			UNION

			SELECT @SeasonKey, @GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, 30 AS MinutesLimit, Points, Games, PlayerMinutes, PPG
			FROM dbo.fnGetPPGByPlayerPlayerPositionDificultyGameweeks(@SeasonKey, @GameweekKey, 4, 30, 10)
		)
		AS Source (SeasonKey, GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, MinutesLimit, Points, Games, PlayerMinutes, PPG)
		ON Target.SeasonKey = Source.SeasonKey
		AND Target.GameweekKey = Source.GameweekKey
		AND Target.PlayerKey = Source.PlayerKey
		AND Target.PlayerPositionKey = Source.PlayerPositionKey
		AND Target.OpponentDifficulty = Source.OpponentDifficulty
		AND Target.MinutesLimit = Source.MinutesLimit
		WHEN MATCHED THEN 
		UPDATE SET Points = Source.Points,
		Games = Source.Games,
		PlayerMinutes = Source.PlayerMinutes,
		PPG = Source.PPG
		WHEN NOT MATCHED BY TARGET THEN 
		INSERT (SeasonKey, GameweekKey, PlayerKey, PlayerPositionKey, OpponentDifficulty, MinutesLimit, Points, Games, PlayerMinutes, PPG)
		VALUES (Source.SeasonKey, Source.GameweekKey, Source.PlayerKey, Source.PlayerPositionKey, Source.OpponentDifficulty, Source.MinutesLimit, Source.Points, Source.Games, Source.PlayerMinutes, Source.PPG);

	END

	SELECT @i = @i + 1;

END
GO