CREATE VIEW dbo.vwPlayerAveragePointsGroupedByDifficultyWasHome
AS
SELECT dp.PlayerKey,
MIN(dp.PlayerName) AS PlayerName,
dtd.Difficulty,
fph.WasHome,
SUM(fph.TotalPoints) AS TotalPoints,
COUNT(DISTINCT fph.PlayerHistoryKey) AS TotalGames,
CAST(AVG(fph.TotalPoints * 1.00) AS DECIMAL(4,2)) AS AvgPoints
FROM dbo.DimPlayer dp
INNER JOIN dbo.FactPlayerHistory fph
ON dp.PlayerKey = fph.PlayerKey
AND fph.[Minutes] > 0
INNER JOIN dbo.DimTeamDifficulty dtd
ON fph.OpponentTeamKey = dtd.TeamKey
AND fph.SeasonKey = dtd.SeasonKey
AND fph.WasHome = dtd.IsOpponentHome
GROUP BY dp.PlayerKey,
dtd.Difficulty,
fph.WasHome;