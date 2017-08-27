PRINT 'Updating dbo.Difficulty';

MERGE INTO dbo.difficulty AS Target 
USING 
(
	VALUES 
	(1,'ARS',4,0,1),
	(1,'ARS',4,1,0),
	(2,'BOU',2,0,1),
	(2,'BOU',2,1,0),
	(3,'BHA',2,0,1),
	(3,'BHA',2,1,0),
	(4,'BUR',3,0,1),
	(4,'BUR',1,1,0),
	(5,'CHE',5,0,1),
	(5,'CHE',5,1,0),
	(6,'CRY',2,0,1),
	(6,'CRY',2,1,0),
	(7,'EVE',4,0,1),
	(7,'EVE',3,1,0),
	(8,'HUD',2,0,1),
	(8,'HUD',1,1,0),
	(9,'LEI',3,0,1),
	(9,'LEI',2,1,0),
	(10,'LIV',4,0,1),
	(10,'LIV',4,1,0),
	(11,'MCI',4,0,1),
	(11,'MCI',4,1,0),
	(12,'MUN',4,0,1),
	(12,'MUN',4,1,0),
	(13,'NEW',2,0,1),
	(13,'NEW',2,1,0),
	(14,'SOU',3,0,1),
	(14,'SOU',2,1,0),
	(15,'STK',2,0,1),
	(15,'STK',2,1,0),
	(16,'SWA',2,0,1),
	(16,'SWA',2,1,0),
	(17,'TOT',5,0,1),
	(17,'TOT',4,1,0),
	(18,'WAT',2,0,1),
	(18,'WAT',2,1,0),
	(19,'WBA',2,0,1),
	(19,'WBA',2,1,0),
	(20,'WHU',2,0,1),
	(20,'WHU',2,1,0)
)
AS Source (teamId, team_short_name, difficulty, is_home, is_opponent_home)
ON Target.teamId = Source.teamId
AND Target.is_home = Source.is_home
WHEN MATCHED THEN 
UPDATE SET team_short_name = Source.team_short_name, difficulty = Source.difficulty, is_opponent_home = Source.is_opponent_home
WHEN NOT MATCHED BY TARGET THEN 
INSERT (teamId, team_short_name, difficulty, is_home, is_opponent_home) 
VALUES (teamId, team_short_name, difficulty, is_home, is_opponent_home)  
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;