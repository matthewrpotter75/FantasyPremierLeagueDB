﻿CREATE PROCEDURE dbo.GetPlayerMinutesByGameweek
(
	@SeasonKey INT = NULL,
	@PlayerKeys VARCHAR(200),
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
	;WITH PlayerGameweekMinutes AS
	(
		SELECT dp.PlayerKey,
		dp.PlayerName, 
		fph.GameweekKey, 
		dpa.PlayerPositionKey,
		dpp.PlayerPositionShort,
		fph.[Minutes] AS PlayerMinutes
		FROM dbo.DimPlayer dp
		INNER JOIN dbo.DimPlayerAttribute dpa
		ON dp.PlayerKey = dpa.PlayerKey
		AND dpa.SeasonKey = @SeasonKey
		INNER JOIN dbo.DimPlayerPosition dpp
		ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
		INNER JOIN dbo.FactPlayerHistory fph
		ON dp.PlayerKey = fph.PlayerKey
		WHERE fph.SeasonKey = @SeasonKey
		AND fph.PlayerKey IN (' + @PlayerKeys + ')
	)
	SELECT PlayerName, PlayerPositionShort, ' + @colHeaders + '
	FROM
	(
		SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, GameweekKey, PlayerMinutes
		FROM PlayerGameweekMinutes pgp
	) src
	PIVOT
	(
		SUM(PlayerMinutes)
		FOR GameweekKey IN (' + @colHeaders + ')
	) piv
	ORDER BY PlayerPositionKey, PlayerKey;';

	IF @Debug = 1
		PRINT @sql;

	DECLARE @ParmDefinition NVARCHAR(500);
	SET @ParmDefinition = N'@SeasonKey INT';
	EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey;

END;