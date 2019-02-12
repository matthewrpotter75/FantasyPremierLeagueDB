CREATE PROCEDURE [dbo].[GetUserTeamPlayerFixturesAndDifficulty]
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@NextGameweekKey INT = NULL,
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
	IF @NextGameweekKey IS NULL
	BEGIN
		SET @NextGameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	SET @LastGameweekKey = @NextGameweekKey + 9;

	DECLARE @Gameweeks TABLE (Id INT IDENTITY(1,1), GameweekKey INT);

	INSERT INTO @Gameweeks (GameweekKey)
	SELECT DISTINCT GameweekKey
	FROM dbo.DimGameweek
	WHERE [GameweekKey] BETWEEN @NextGameweekKey AND @LastGameweekKey
	ORDER BY [GameweekKey];

	DECLARE @colHeaders VARCHAR(200);

	SELECT @colHeaders = STUFF((SELECT  '],[' + CAST(GameweekKey AS VARCHAR(2))
    FROM @Gameweeks
    ORDER BY GameweekKey
    FOR XML PATH('')), 1, 2, '') + ']';

	DECLARE @sql NVARCHAR(4000);

	IF @UserTeamKey IS NOT NULL
	BEGIN
	
		SET @sql = 'DECLARE @CurrentGameweekKey INT;
		SELECT @CurrentGameweekKey = MAX(GameweekKey) FROM dbo.DimGameweek WHERE SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + ' AND DeadlineTime < GETDATE();
	
		;WITH PlayerOpponentDifficulty AS
		(
			SELECT dp.PlayerKey,
			dp.PlayerName, 
			dtgwf.GameweekKey, 
			pcs.Cost,
			hdt.TeamName,
			dpa.PlayerPositionKey,
			dpp.PlayerPositionShort AS PlayerPosition,
			dt.TeamShortName + '' ('' + CASE WHEN IsHome = 1 THEN ''H'' ELSE ''A'' END + '') D'' + CAST(dtd.Difficulty AS VARCHAR(1)) AS Opponent
			FROM dbo.DimUserTeamPlayer utp
			INNER JOIN dbo.DimPlayer dp
			ON utp.PlayerKey = dp.PlayerKey
			INNER JOIN dbo.DimPlayerAttribute dpa
			ON utp.PlayerKey = dpa.PlayerKey
			AND dpa.SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + '
			INNER JOIN dbo.DimTeam hdt
			ON dpa.TeamKey = hdt.TeamKey
			INNER JOIN dbo.DimPlayerPosition dpp
			ON dpa.PlayerPositionKey = dpp.PlayerPositionKey
			INNER JOIN dbo.DimTeamGameweekFixture dtgwf
			ON dpa.TeamKey = dtgwf.TeamKey
			AND dpa.SeasonKey = dtgwf.SeasonKey
			INNER JOIN dbo.DimTeam dt
			ON dtgwf.OpponentTeamKey = dt.TeamKey
			INNER JOIN dbo.DimTeamDifficulty dtd
			ON dtgwf.OpponentTeamKey = dtd.TeamKey
			AND dtgwf.IsHome = dtd.IsOpponentHome
			AND dtd.SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + '
			INNER JOIN dbo.FactPlayerCurrentStats pcs
			ON utp.PlayerKey = pcs.PlayerKey
			WHERE utp.UserTeamKey = ' + CAST(@UserTeamKey AS VARCHAR(3)) + '
			AND dtgwf.SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + '
			AND utp.GameweekKey = ' + CAST(@NextGameweekKey AS VARCHAR(3)) + '
			AND utp.SeasonKey = ' + CAST(@SeasonKey AS VARCHAR(3)) + '
		)
		SELECT PlayerName, PlayerPosition, Cost, TeamName, ' + @colHeaders + '
		FROM
		(
			SELECT DISTINCT PlayerName, PlayerKey, PlayerPosition, PlayerPositionKey, GameweekKey, TeamName, Cost, LEFT(r.Opponent , LEN(r.Opponent)-1) AS Opponent
			FROM PlayerOpponentDifficulty pod
			CROSS APPLY
			(
				SELECT r.Opponent + '', ''
				FROM PlayerOpponentDifficulty r
				WHERE pod.PlayerKey = r.PlayerKey
				  and pod.GameweekKey = r.GameweekKey
				FOR XML PATH('''')
			) r (Opponent)
		) src
		PIVOT
		(
			MIN(Opponent)
			FOR GameweekKey IN (' + @colHeaders + ')
		) piv
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