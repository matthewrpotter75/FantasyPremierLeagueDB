CREATE PROCEDURE dbo.ComparePlayersByTeamAndPosition
(
	@teamShortName VARCHAR(3),
	@playerPosition VARCHAR(3)
)
AS
BEGIN

	DECLARE @cols AS NVARCHAR(MAX),
			@selectcols AS NVARCHAR(MAX),
			@query  AS NVARCHAR(MAX)

	SELECT @cols = STUFF((
							SELECT ',' + QUOTENAME(p.id) AS playerId
							FROM 
							(
								SELECT ph.playerId
								FROM dbo.PlayerHistory ph
								INNER JOIN dbo.Players p
								ON ph.playerId = p.id
								INNER JOIN dbo.PlayerPositions pp
								ON p.playerPositionId = pp.id
								INNER JOIN dbo.Teams t
								ON p.teamId = t.id
								WHERE t.short_name = @teamShortName
								AND pp.singular_name_short = @playerPosition
								GROUP BY ph.playerId
								HAVING SUM(ph.[minutes]) > 0
							) pids
							INNER JOIN dbo.Players p
							ON pids.playerId = p.id
							ORDER BY playerId

				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'');

	--SELECT @cols;

	SELECT @selectcols = STUFF((
							SELECT ',ISNULL(' + QUOTENAME(p.id) + ',0) AS [' + p.first_name + ' ' + p.second_name + ']'
							FROM 
							(
								SELECT ph.playerId
								FROM dbo.PlayerHistory ph
								INNER JOIN dbo.Players p
								ON ph.playerId = p.id
								INNER JOIN dbo.PlayerPositions pp
								ON p.playerPositionId = pp.id
								INNER JOIN dbo.Teams t
								ON p.teamId = t.id
								WHERE t.short_name = @teamShortName
								AND pp.singular_name_short = @playerPosition
								GROUP BY ph.playerId
								HAVING SUM(ph.[minutes]) > 0
							) pids
							INNER JOIN dbo.Players p
							ON pids.playerId = p.id
							ORDER BY playerId

				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'');

	--SELECT @selectcols;

	SET @query = 'SELECT gameweekId,' + @selectcols + ' FROM 
				 (
					SELECT ph.gameweekId, p.id AS playerId, ph.[minutes]
					FROM dbo.PlayerHistory ph
					INNER JOIN dbo.Players p
					ON ph.playerId = p.id
					INNER JOIN dbo.PlayerPositions pp
					ON p.playerPositionId = pp.id
					INNER JOIN dbo.Teams t
					ON p.teamId = t.id
					WHERE t.short_name = ''' + @teamShortName + '''
					AND pp.singular_name_short = ''' + @playerPosition + '''
				) x
				PIVOT 
				(
					SUM([minutes])
					FOR playerId IN (' + @cols + ')
				) p ';

	--SELECT @query;
	EXEC(@query);

END