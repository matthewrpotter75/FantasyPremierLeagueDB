CREATE PROCEDURE dbo.GetUserTeamPlayerPointsPlayingAndBenchPlayers
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
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

	IF @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END

	DECLARE @LastGameweekKey INT;
	SET @LastGameweekKey = (SELECT MAX(GameweekKey) FROM dbo.FactPlayerHistory WHERE SeasonKey = @SeasonKey);

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek
	WHERE GameweekKey BETWEEN 1 AND @LastGameweekKey
	ORDER BY GameweekKey;

	DECLARE @NumGameweeks INT;
	SELECT @NumGameweeks = MAX(GameweekKey) FROM @Gameweeks;

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

	DECLARE @sql NVARCHAR(4000);
	
	--SET @sql = 'DECLARE @CurrentGameweekKey INT;
	--SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = @SeasonKey AND DeadlineTime < GETDATE();

	IF @UserTeamKey IS NOT NULL
	BEGIN

		SET @sql = '	
		;WITH PlayerGameweekPoints AS
			(
				SELECT dp.PlayerKey,
				dp.PlayerName, 
				fph.GameweekKey, 
				dpa.PlayerPositionKey,
				dpp.PlayerPositionShort,
				fph.TotalPoints
				FROM dbo.DimUserTeamPlayer my
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
				WHERE my.UserTeamKey = @UserTeamKey
				AND fph.SeasonKey = @SeasonKey
				AND my.IsPlay = 1
			),
			PlayerGameweekPointsBench AS
			(
				SELECT dp.PlayerKey,
				dp.PlayerName, 
				fph.GameweekKey, 
				dpa.PlayerPositionKey,
				dpp.PlayerPositionShort,
				fph.TotalPoints
				FROM dbo.DimUserTeamPlayer my
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
				WHERE my.UserTeamKey = @UserTeamKey
				AND fph.SeasonKey = @SeasonKey
				AND my.IsPlay = 0
			),
			PlayerPoints AS
			(
				SELECT PlayerKey, PlayerPositionKey, PlayerName, PlayerPositionShort, ' + @colHeaders + '
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
			),
			BenchPoints AS
			(
				SELECT PlayerKey, PlayerPositionKey, PlayerName, PlayerPositionShort, ' + @colHeaders + '
				FROM
				(
					SELECT DISTINCT PlayerName, PlayerKey, PlayerPositionShort, PlayerPositionKey, GameweekKey, TotalPoints
					FROM PlayerGameweekPointsBench pgp
				) src
				PIVOT
				(
					SUM(TotalPoints)
					FOR GameweekKey IN (' + @colHeaders + ')
				) piv
			),
			FinalQuery (PlayerName, PlayerPositionShort, PlayerPositionKey, PlayerKey, ' + @colHeaders + ') AS
			(
				SELECT ISNULL(pp.PlayerName,bp.PlayerName) AS PlayerName, 
				ISNULL(pp.PlayerPositionShort,bp.PlayerPositionShort) AS PlayerPositionShort,
				ISNULL(pp.PlayerPositionKey,bp.PlayerPositionKey) AS PlayerPositionKey,
				ISNULL(pp.PlayerKey,bp.PlayerKey) AS PlayerKey,';

		DECLARE @i INT = 1;
	
		WHILE @i <= @NumGameweeks
		BEGIN

			SET @sql = @sql + 'ISNULL(CAST(pp.[' + CAST(@i AS VARCHAR(2)) + '] AS VARCHAR(2)),''-'') + '' ('' + ISNULL(CAST(bp.[' + CAST(@i AS VARCHAR(2)) + '] AS VARCHAR(2)),''-'') + '')'','
			SET @i = @i + 1;

		END

		SET @sql = LEFT(@sql,LEN(@sql)-1);

		SET @sql = @sql + '
				FROM PlayerPoints pp
				FULL JOIN BenchPoints bp
				ON pp.PlayerKey = bp.PlayerKey
			)
			SELECT *
			FROM FinalQuery
			ORDER BY PlayerPositionKey, PlayerKey;';

		DECLARE @ParmDefinition NVARCHAR(500);
		SET @ParmDefinition = N'@SeasonKey INT';
		EXEC sp_executesql @sql, @ParmDefinition, @SeasonKey = @SeasonKey;

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

	IF @Debug = 1
		PRINT @sql;

END;