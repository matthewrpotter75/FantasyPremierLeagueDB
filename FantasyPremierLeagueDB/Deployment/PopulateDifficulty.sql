DECLARE @sScriptName VARCHAR(256) = N'PopulateDifficulty.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;
GO

MERGE INTO dbo.difficulty AS Target 
USING 
(
	VALUES 
	(1,'ARS',4,0,1),
	(1,'ARS',4,1,0),
	(2,'AVL',2,0,1),
	(2,'AVL',2,1,0),
	(3,'BOU',2,0,1),
	(3,'BOU',3,1,0),
	(4,'BHA',2,0,1),
	(4,'BHA',2,1,0),
	(5,'BUR',2,0,1),
	(5,'BUR',2,1,0),
	(6,'CHE',4,0,1),
	(6,'CHE',4,1,0),
	(7,'CRY',3,0,1),
	(7,'CRY',2,1,0),
	(8,'EVE',2,0,1),
	(8,'EVE',4,1,0),
	(9,'LEI',3,0,1),
	(9,'LEI',3,1,0),
	(10,'LIV',4,0,1),
	(10,'LIV',5,1,0),
	(11,'MCI',4,0,1),
	(11,'MCI',5,1,0),
	(12,'MUN',4,0,1),
	(12,'MUN',4,1,0),
	(13,'NEW',2,0,1),
	(13,'NEW',3,1,0),
	(14,'NOR',2,0,1),
	(14,'NOR',2,1,0),
	(15,'SHU',2,0,1),
	(15,'SHU',2,1,0),
	(16,'SOU',2,0,1),
	(16,'SOU',2,1,0),
	(17,'TOT',4,0,1),
	(17,'TOT',4,1,0),
	(18,'WAT',3,0,1),
	(18,'WAT',3,1,0),
	(19,'WHU',2,0,1),
	(19,'WHU',3,1,0),
	(20,'WOL',3,0,1),
	(20,'WOL',3,1,0)
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

DECLARE @sScriptName VARCHAR(256) = N'PopulateDifficulty.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO