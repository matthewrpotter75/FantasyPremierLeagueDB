PRINT 'Updating dbo.GameweekFixtures';

MERGE INTO dbo.GameweekFixtures AS Target 
USING 
(
	SELECT f.Id, f.gameweekId, f.team_h AS homeTeamId, f.team_a AS awayTeamId, ht.short_name AS homeTeam_Shortname, at.short_name AS awayTeam_Shortname, f.kickoff_time
	FROM dbo.Fixtures f
	INNER JOIN dbo.Teams ht
	ON f.team_h = ht.id
	INNER JOIN dbo.Teams at
	ON f.team_a = at.id
	WHERE f.gameweekId IS NOT NULL
)
AS Source
ON Target.Id = Source.Id
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
VALUES (Source.Id, Source.gameweekId, Source.homeTeamId, Source.awayTeamId, Source.homeTeam_Shortname, Source.awayTeam_Shortname, Source.kickoff_time);