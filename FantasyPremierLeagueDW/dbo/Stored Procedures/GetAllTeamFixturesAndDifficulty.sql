CREATE PROCEDURE dbo.GetAllTeamFixturesAndDifficulty
(
	@SeasonKey INT = NULL,
	@NextGameweekKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = [SeasonKey] FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @LastGameweekKey INT;
	IF @NextGameweekKey IS NULL
	BEGIN
		SET @NextGameweekKey = (SELECT TOP (1) [GameweekKey] FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	SET @LastGameweekKey = @NextGameweekKey + 9;

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT [GameweekKey]
	FROM dbo.DimGameweek
	WHERE [GameweekKey] BETWEEN @NextGameweekKey AND @LastGameweekKey
	ORDER BY [GameweekKey];

	DECLARE @colHeaders VARCHAR(200);

	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	DECLARE @sql NVARCHAR(4000);
	
	SET @sql = ';WITH PlayerOpponentDifficulty AS
	(
		SELECT dt.TeamShortName AS TeamName, 
		dtgwf.GameweekKey, 
		dt.TeamKey,
		dto.TeamShortName + '' ('' + CASE WHEN dtgwf.IsHome = 1 THEN ''H'' ELSE ''A'' END + '') D'' + CAST(dtd.Difficulty AS VARCHAR(1)) AS Opponent
		FROM dbo.DimTeam dt
		INNER JOIN dbo.DimTeamGameweekFixture dtgwf
		ON dtgwf.TeamKey = dt.TeamKey
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON dtgwf.OpponentTeamKey = dtd.TeamKey
		AND dtgwf.IsHome = dtd.IsOpponentHome
		AND dtd.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimTeam dto
		ON dtgwf.OpponentTeamKey = dto.TeamKey
		WHERE dtgwf.SeasonKey = @SeasonKey
		AND dtgwf.IsScheduled = 1
	),
	AveDifficulty AS
	(
		SELECT dt.TeamShortName AS TeamName, 
		CAST(SUM(dtd.Difficulty * 1.00)/COUNT(dtd.Difficulty) AS DECIMAL(4,2)) AS AverageDifficulty,
		SUM(dtd.Difficulty) AS sumDifficulty,
		COUNT(dtd.Difficulty) AS cntDifficulty,
		MIN(dtd.Difficulty) AS MinDifficulty,
		MAX(dtd.Difficulty) AS MaxDifficulty
		FROM dbo.DimTeam dt
		INNER JOIN dbo.DimTeamGameweekFixture dtgwf
		ON dtgwf.TeamKey = dt.TeamKey
		INNER JOIN dbo.DimTeamDifficulty dtd
		ON dtgwf.OpponentTeamKey = dtd.TeamKey
		AND dtgwf.IsHome = dtd.IsOpponentHome
		AND dtd.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimTeam dto
		ON dtgwf.OpponentTeamKey = dto.TeamKey
		WHERE dtgwf.SeasonKey = @SeasonKey
		AND dtgwf.GameweekKey BETWEEN @NextGameweekKey AND @LastGameweekKey
		GROUP BY dt.TeamShortName
	),
	UpcomingFixtureDifficulty
	AS
	(
		SELECT TeamName, ' + @colHeaders + '
		FROM
		(
			SELECT DISTINCT TeamName, GameweekKey, LEFT(r.Opponent , LEN(r.Opponent)-1) Opponent
			FROM PlayerOpponentDifficulty pod
			CROSS APPLY
			(
				SELECT r.Opponent + '', ''
				FROM PlayerOpponentDifficulty r
				WHERE pod.TeamKey = r.TeamKey
				  and pod.GameweekKey = r.GameweekKey
				FOR XML PATH('''')
			) r (Opponent)
		) src
		PIVOT
		(
			MIN(Opponent)
			FOR GameweekKey IN (' + @colHeaders + ')
		) piv
	)
	SELECT ufd.*, ave.MinDifficulty, ave.MaxDifficulty, ave.AverageDifficulty
	FROM UpcomingFixtureDifficulty ufd
	INNER JOIN AveDifficulty ave
	ON ufd.TeamName = ave.TeamName
	ORDER BY TeamName;'

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT, @NextGameweekKey INT, @LastGameweekKey INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @NextGameweekKey = @NextGameweekKey, @LastGameweekKey = @LastGameweekKey;

END;
GO