CREATE PROCEDURE dbo.GetPossibleTeamPlayerPointsPlayingAndBenchPlayers
(
	@SeasonKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..##PlayerPoints') IS NOT NULL
		DROP TABLE ##PlayerPoints;

	IF OBJECT_ID('tempdb..##BenchPoints') IS NOT NULL
		DROP TABLE ##BenchPoints

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @LastGameweekKey INT;
	SET @LastGameweekKey = (SELECT MAX(GameweekKey) FROM dbo.FactPlayerHistory WHERE SeasonKey = @SeasonKey);

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek
	WHERE GameweekKey BETWEEN 1 AND @LastGameweekKey
	ORDER BY GameweekKey;

	IF @Debug = 1
	BEGIN
		SELECT *
		FROM @Gameweeks;
	END

	DECLARE @ColHeaders NVARCHAR(MAX);

	SELECT @ColHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	DECLARE @FinalQryCols NVARCHAR(MAX);

	SELECT @FinalQryCols = STUFF((SELECT  ',ISNULL(CAST(pp.[' + CAST(GameweekKey AS VARCHAR(2)) + '] AS VARCHAR(2)),''-'') + '' ('' + ISNULL(CAST(bp.[' + CAST(GameweekKey AS VARCHAR(2)) + '] AS VARCHAR(2)),''-'') + '')'''
	--SELECT @FinalQryCols = STUFF((SELECT  ',ISNULL(STR(pp.[' + CAST(GameweekKey AS VARCHAR(2)) + ']),''-'') + '' ('' + ISNULL(STR(bp.[' + CAST(GameweekKey AS VARCHAR(2)) + ']),''-'') + '')'''
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 1, '');

	IF @Debug = 1
	BEGIN
		SELECT @ColHeaders AS ColHeaders;
		SELECT @FinalQryCols AS FinalQryCols;
		SELECT LEN(@ColHeaders) AS LengthColHeaders;
		SELECT LEN(@FinalQryCols) AS LengthFinalQryCols;
	END

	DECLARE @sql NVARCHAR(MAX),
			@sqlBenchPoints NVARCHAR(MAX),
			@sqlPlayerPoints NVARCHAR(MAX);
	
	--SET @sql = 'DECLARE @CurrentGameweekKey INT;
	--SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE();

	SELECT dp.PlayerKey,
	dp.PlayerName, 
	fph.GameweekKey, 
	dpa.PlayerPositionKey,
	dpp.PlayerPositionShort,
	fph.TotalPoints,
	pt.IsPlay
	INTO #PlayerGameweekPoints
	FROM dbo.PossibleTeam pt
	INNER JOIN dbo.DimPlayer dp
	ON pt.PlayerKey = dp.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute dpa
	ON pt.PlayerKey = dpa.PlayerKey
	AND dpa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimPlayerPosition dpp
	ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
	INNER JOIN dbo.FactPlayerHistory fph
	ON dp.PlayerKey = fph.PlayerKey
	AND pt.GameweekKey = fph.GameweekKey
	WHERE fph.SeasonKey = @SeasonKey;

	SET @sqlPlayerPoints = '
		SELECT PlayerKey, PlayerPositionKey AS PositionKey, PlayerName, PlayerPositionShort AS PlayerPosition, ' + @ColHeaders + '
		INTO ##PlayerPoints
		FROM
		(
			SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, GameweekKey, TotalPoints
			FROM #PlayerGameweekPoints
			WHERE IsPlay = 1
		) src
		PIVOT
		(
			SUM(TotalPoints)
			FOR GameweekKey IN (' + @ColHeaders + ')
		) piv;';

	IF @Debug = 1
		PRINT @sqlPlayerPoints;

	EXEC sp_executesql @sqlPlayerPoints;

	SET @sqlBenchPoints = '
		SELECT PlayerKey, PlayerPositionKey AS PositionKey, PlayerName, PlayerPositionShort AS PlayerPosition, ' + @ColHeaders + '
		INTO ##BenchPoints
		FROM
		(
			SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, GameweekKey, TotalPoints
			FROM #PlayerGameweekPoints
			WHERE IsPlay = 0
		) src
		PIVOT
		(
			SUM(TotalPoints)
			FOR GameweekKey IN (' + @ColHeaders + ')
		) piv;';

	IF @Debug = 1
		PRINT @sqlBenchPoints;

	EXEC sp_executesql @sqlBenchPoints;

	DECLARE @FinalQrySQL1 NVARCHAR(MAX),
			@FinalQrySQL2 NVARCHAR(MAX),
			@FinalQrySQL3 NVARCHAR(MAX);

	SET @FinalQrySQL1 = N';WITH FinalQuery (Player,Position,PPKey,PlayerKey,';

	SET @FinalQrySQL2 = N') AS
			(
			SELECT ISNULL(pp.PlayerName,bp.PlayerName), 
			ISNULL(pp.PlayerPosition,bp.PlayerPosition),
			ISNULL(pp.PositionKey,bp.PositionKey),
			ISNULL(pp.PlayerKey,bp.PlayerKey),
			';

	SET @FinalQrySQL3 = N'
			FROM ##PlayerPoints pp
			FULL JOIN ##BenchPoints bp
			ON pp.PlayerKey = bp.PlayerKey
		)
		SELECT *
		FROM FinalQuery
		ORDER BY PPKey, PlayerKey;';

	SET @sql = @FinalQrySQL1;
	SET @sql = CONCAT(@sql, @ColHeaders, @FinalQrySQL2, @FinalQryCols, @FinalQrySQL3);

	IF @Debug = 1
	BEGIN
		PRINT @sql;
		SELECT LEN(@FinalQrySQL1) AS FinalQrySQL1,LEN(@FinalQrySQL2) AS FinalQrySQL2,LEN(@FinalQrySQL3) AS FinalQrySQL3,LEN(@ColHeaders) AS ColHeaders, LEN(@FinalQryCols) AS FinalQryCols
		SELECT LEN(@sql) AS LengthSQL;
	END

	DECLARE @ParmDefinition NVARCHAR(MAX);
	SET @ParmDefinition = N'@SeasonKey INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey;

END;