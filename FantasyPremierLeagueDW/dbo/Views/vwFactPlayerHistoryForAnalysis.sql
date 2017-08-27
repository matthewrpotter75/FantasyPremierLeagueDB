CREATE VIEW vwFactPlayerHistoryForAnalysis
AS
SELECT fph.[PlayerHistoryKey], 
fph.[PlayerKey], 
dpa.[TeamKey],
fph.[OpponentTeamKey],
fph.[SeasonKey], 
fph.[GameweekKey], 
fph.value AS PlayerCost,
dpa.[PlayerPositionKey], 
CAST(fph.WasHome AS INT) AS WasHome,
dtd.Difficulty,
odtd.Difficulty AS OppositionDifficulty, 
CASE WHEN fph.WasHome = 1 THEN dta.StrengthOverallHome ELSE dta.StrengthOverallAway END TeamOverallStrength,
CASE WHEN fph.WasHome = 1 THEN dta.StrengthDefenceHome ELSE dta.StrengthDefenceAway END TeamStrengthDefence,
CASE WHEN fph.WasHome = 1 THEN dta.StrengthAttackHome ELSE dta.StrengthAttackAway END TeamStrengthAttack,
CASE WHEN fph.WasHome = 0 THEN odta.StrengthDefenceHome ELSE odta.StrengthDefenceAway END OppositionStrengthDefence,
CASE WHEN fph.WasHome = 0 THEN odta.StrengthOverallHome ELSE odta.StrengthOverallAway END OppositionOverallStrength,
CASE WHEN fph.WasHome = 0 THEN odta.StrengthAttackHome ELSE odta.StrengthAttackAway END OppositionStrengthAttack,
fph.[Minutes] AS GameMinutes,
fph.TotalPoints
FROM dbo.FactPlayerHistory fph
INNER JOIN dbo.DimPlayerAttribute dpa
ON fph.[PlayerKey] = dpa.[PlayerKey]
AND fph.[SeasonKey] = dpa.[SeasonKey]
INNER JOIN dbo.DimTeamAttribute dta
ON dpa.[TeamKey] = dta.[TeamKey]
AND fph.[SeasonKey] = dta.[SeasonKey]
INNER JOIN dbo.DimTeamDifficulty dtd
ON dta.[TeamKey] = dtd.TeamKey
AND fph.[SeasonKey] = dtd.SeasonKey
AND fph.WasHome = dtd.IsTeamHome
INNER JOIN dbo.DimTeamDifficulty odtd
ON fph.[OpponentTeamKey] = odtd.TeamKey
AND fph.[SeasonKey] = odtd.SeasonKey
AND fph.WasHome = odtd.IsOpponentHome
INNER JOIN dbo.DimTeamAttribute odta
ON fph.[OpponentTeamKey] = odta.[TeamKey]
AND fph.[SeasonKey] = odta.[SeasonKey]
WHERE fph.[Minutes] > 0;