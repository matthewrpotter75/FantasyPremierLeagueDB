CREATE PROCEDURE dbo.GetBestTeamPlayerPointsForEachGameweekInRange
(
	@SeasonKey INT = NULL,
	@GameweekStart INT,
	@GameweekEnd INT,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek
	WHERE GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	ORDER BY GameweekKey;

	IF @Debug = 1
	BEGIN
		SELECT *
		FROM @Gameweeks;
	END

	DECLARE @colHeaders VARCHAR(25);
	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	IF @Debug = 1
		SELECT @colHeaders;

	DECLARE @sql NVARCHAR(2000);
	
	--SET @sql = 'DECLARE @CurrentGameweekKey INT;
	--SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE();

	SET @sql = '	
	;WITH PlayerGameweekPoints AS
	(
		SELECT bt.PlayerKey,
		p.PlayerName, 
		bt.GameweekKey, 
		bt.PlayerPositionKey,
		pp.PlayerPositionShort,
		bt.Cost,
		bt.TotalPoints
		FROM dbo.BestTeam bt
		INNER JOIN dbo.DimPlayer p
		ON bt.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON bt.PlayerPositionKey = pp.PlayerPositionKey
		WHERE bt.SeasonKey = @SeasonKey
		AND bt.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	)
	SELECT PlayerName, PlayerPositionShort, Cost, ' + @colHeaders + '
	FROM
	(
		SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, Cost, GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv
	ORDER BY PlayerPositionKey, ' + @colHeaders + ', PlayerKey;';

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT, @GameweekStart INT, @GameweekEnd INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey, @GameweekStart = @GameweekStart, @GameweekEnd = @GameweekEnd;

END