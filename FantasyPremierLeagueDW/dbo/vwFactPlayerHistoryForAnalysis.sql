CREATE VIEW vwFactPlayerHistoryForAnalysis
AS
SELECT fph.PlayerHistoryId, 
fph.PlayerId, 
dpa.TeamId,
fph.OpponentTeamId,
fph.SeasonId, 
fph.GameweekId, 
fph.value AS PlayerCost,
dpa.PlayerPositionId, 
fph.WasHome, 
dtd.Difficulty,
odtd.Difficulty AS OppositionDifficulty, 
CASE WHEN fph.WasHome = 1 THEN dta.StrengthOverallHome ELSE dta.StrengthOverallAway END TeamOverallStrength,
CASE WHEN fph.WasHome = 1 THEN dta.StrengthDefenceHome ELSE dta.StrengthDefenceAway END TeamStrengthDefence,
CASE WHEN fph.WasHome = 1 THEN dta.StrengthAttackHome ELSE dta.StrengthAttackAway END TeamStrengthAttack,
CASE WHEN fph.WasHome = 0 THEN odta.StrengthDefenceHome ELSE odta.StrengthDefenceAway END OppositionStrengthDefence,
CASE WHEN fph.WasHome = 0 THEN odta.StrengthOverallHome ELSE odta.StrengthOverallAway END OppositionOverallStrength,
CASE WHEN fph.WasHome = 0 THEN odta.StrengthAttackHome ELSE odta.StrengthAttackAway END OppositionStrengthAttack,
fph.[Minutes],
fph.TotalPoints
FROM dbo.FactPlayerHistory fph
INNER JOIN dbo.DimPlayerAttribute dpa
ON fph.PlayerId = dpa.PlayerId
AND fph.SeasonId = dpa.SeasonId
INNER JOIN dbo.DimTeamAttribute dta
ON dpa.TeamId = dta.TeamId
AND fph.SeasonId = dta.SeasonId
INNER JOIN dbo.DimTeamDifficulty dtd
ON dta.TeamId = dtd.TeamId
AND fph.SeasonId = dtd.SeasonId
AND fph.WasHome = dtd.IsTeamHome
INNER JOIN dbo.DimTeamDifficulty odtd
ON fph.OpponentTeamId = odtd.TeamId
AND fph.SeasonId = odtd.SeasonId
AND fph.WasHome = odtd.IsOpponentHome
INNER JOIN dbo.DimTeamAttribute odta
ON fph.OpponentTeamId = odta.TeamId
AND fph.SeasonId = odta.SeasonId
WHERE fph.[Minutes] > 0;