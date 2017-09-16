MERGE INTO dbo.DimPlayerTeamGameweekFixture AS Target 
USING 
(
	SELECT ph.PlayerKey, tgf.TeamKey, ph.GameweekKey, ph.SeasonKey, ph.GameweekFixtureKey, ph.WasHome
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.[DimTeamGameweekFixture] tgf
	ON ph.GameweekFixtureKey = tgf.GameweekFixtureKey
	AND ph.OpponentTeamKey = tgf.OpponentTeamKey
	--ORDER BY ph.PlayerKey, tgf.TeamKey, ph.GameweekKey, ph.SeasonKey, ph.GameweekFixtureKey
)
AS Source (PlayerKey, TeamKey, GameweekKey, SeasonKey, GameweekFixtureKey, IsHome)
ON Target.PlayerKey = Source.PlayerKey
AND Target.TeamKey = Source.TeamKey
AND Target.GameweekKey = Source.GameweekKey
AND Target.SeasonKey = Source.SeasonKey
AND Target.GameweekFixtureKey = Source.GameweekFixtureKey
WHEN MATCHED THEN 
UPDATE SET IsHome = Source.IsHome
WHEN NOT MATCHED BY TARGET THEN 
INSERT (PlayerKey, TeamKey, GameweekKey, SeasonKey, GameweekFixtureKey, IsHome) 
VALUES (PlayerKey, TeamKey, GameweekKey, SeasonKey, GameweekFixtureKey, IsHome);