CREATE PROCEDURE dbo.GetMyTeamActualPlayerPointsForEachGameweekInRange
(
	@SeasonKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

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

	DECLARE @colHeaders VARCHAR(200);

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
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		fph.GameweekKey, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		fph.TotalPoints
		FROM dbo.MyTeam my
		INNER JOIN dbo.DimPlayer dp
		ON my.PlayerKey = dp.PlayerKey
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON my.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		AND my.GameweekKey = fph.GameweekKey
		WHERE fph.SeasonKey = @SeasonKey
	)
	SELECT PlayerName, PlayerPositionShort, ' + @colHeaders + '
	FROM
	(
		SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, GameweekKey, TotalPoints
		FROM PlayerGameweekPoints pgp
	) src
	PIVOT
	(
		SUM(TotalPoints)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv
	ORDER BY PlayerPositionKey, PlayerKey;';

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey;

END;