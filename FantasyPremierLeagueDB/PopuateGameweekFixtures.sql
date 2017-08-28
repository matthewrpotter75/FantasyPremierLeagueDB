PRINT 'Updating dbo.GameweekFixtures';

MERGE INTO dbo.GameweekFixtures AS Target 
USING 
(
	SELECT ISNULL(f.id,0) AS id, ph.gameweekId, t.id AS homeTeamId, ot.id AS awayTeamId, t.short_name AS homeTeam_Shortname, ot.short_name AS awayTeam_Shortname, ph.kickoff_time--, COUNT(DISTINCT ph.playerId) AS playerCount
	FROM dbo.PlayerHistory ph
	INNER JOIN dbo.Teams ot
	ON ph.opponent_teamId = ot.id
	INNER JOIN dbo.Players p
	ON ph.playerId = p.id
	INNER JOIN dbo.Teams t
	ON p.teamId = t.id
	LEFT JOIN dbo.Fixtures f
	ON ph.gameweekId = f.gameweekId
	AND t.id = f.team_h
	AND ot.id = f.team_a
	WHERE ph.was_home = 1
	GROUP BY f.id, ph.gameweekId, t.id, ot.id, t.short_name, ot.short_name, ph.kickoff_time
	HAVING COUNT(DISTINCT ph.playerId) > 2

	UNION

	SELECT f.id, f.gameweekId, f.team_h, f.team_a, ht.short_name, at.short_name, f.kickoff_time
	FROM dbo.Fixtures f
	INNER JOIN dbo.Teams ht
	ON f.team_h = ht.id
	INNER JOIN dbo.Teams at
	ON f.team_a = at.id
	WHERE f.gameweekId IS NOT NULL
)
AS Source
ON Target.gameweekId = Source.gameweekId
AND Target.homeTeamId = Source.homeTeamId
AND Target.awayTeamId = Source.awayTeamId
WHEN MATCHED THEN 
UPDATE SET 
gameweekId = Source.gameweekId,
homeTeamId = Source.homeTeamId,
awayTeamId = Source.awayTeamId,
homeTeam_Shortname = Source.homeTeam_Shortname, 
awayTeam_Shortname = Source.awayTeam_Shortname,
kickoff_time = Source.kickoff_time
WHEN NOT MATCHED BY TARGET THEN 
INSERT (Id, gameweekId, homeTeamId, awayTeamId, homeTeam_Shortname, awayTeam_Shortname, kickoff_time) 
VALUES (Source.Id, Source.gameweekId, Source.homeTeamId, Source.awayTeamId, Source.homeTeam_Shortname, Source.awayTeam_Shortname, Source.kickoff_time)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;