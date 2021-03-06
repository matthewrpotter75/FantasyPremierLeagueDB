CREATE VIEW dbo.vwPlayerAveragePointsByDifficulty
AS
SELECT
pp.PlayerKey,
pp.PlayerName,
dpp.PlayerPositionShort AS PlayerPosition,
CAST(pp.TotalPoints AS INT) AS TotalPoints,
pp.TotalGames,
CASE WHEN pp.TotalGames > 0 THEN CAST(pp.TotalPoints/pp.TotalGames AS DECIMAL(4,2)) ELSE 0 END AS AvgPts,
CAST(pp.HomePoints AS INT) AS HomePoints,
pp.HomeGames,
CASE WHEN pp.HomeGames > 0 THEN CAST(pp.HomePoints/pp.HomeGames AS DECIMAL(4,2)) ELSE 0 END AS HomeAvgPts,
CAST(pp.AwayPoints AS INT) AS AwayPoints,
pp.AwayGames,
CASE WHEN pp.AwayGames > 0 THEN CAST(pp.AwayPoints/pp.AwayGames AS DECIMAL(4,2)) ELSE 0 END AS AwayAvgPts,
CASE WHEN pp.Diff1Games > 0 THEN CAST(pp.Diff1Points/pp.Diff1Games AS DECIMAL(4,2)) ELSE 0 END AS D1AvgPts,
CAST(pp.Diff1HomePoints AS INT) AS D1HPts,
pp.Diff1HomeGames AS D1HGames,
CASE WHEN pp.Diff1HomeGames > 0 THEN CAST(pp.Diff1HomePoints/pp.Diff1HomeGames AS DECIMAL(4,2)) ELSE 0 END AS D1HAvgPts,
CAST(pp.Diff1AwayPoints AS INT) AS D1APts,
pp.Diff1AwayGames AS D1AGames,
CASE WHEN pp.Diff1AwayGames > 0 THEN CAST(pp.Diff1AwayPoints/pp.Diff1AwayGames AS DECIMAL(4,2)) ELSE 0 END AS D1AAvgPts,
CASE WHEN pp.Diff2Games > 0 THEN CAST(pp.Diff2Points/pp.Diff2Games AS DECIMAL(4,2)) ELSE 0 END AS D2AvgPts,
CAST(pp.Diff2HomePoints AS INT) AS D2HPts,
pp.Diff2HomeGames AS D2HGames,
CASE WHEN pp.Diff2HomeGames > 0 THEN CAST(pp.Diff2HomePoints/pp.Diff2HomeGames AS DECIMAL(4,2)) ELSE 0 END AS D2HAvgPts,
CAST(pp.Diff2AwayPoints AS INT) AS D2APts,
pp.Diff2AwayGames AS D2AGames,
CASE WHEN pp.Diff2AwayGames > 0 THEN CAST(pp.Diff2AwayPoints/pp.Diff2AwayGames AS DECIMAL(4,2)) ELSE 0 END AS D2AAgPts,
CASE WHEN pp.Diff3Games > 0 THEN CAST(pp.Diff3Points/pp.Diff3Games AS DECIMAL(4,2)) ELSE 0 END AS D3AvgPts,
CAST(pp.Diff3HomePoints AS INT) AS D3HPts,
pp.Diff3HomeGames AS D3HGames,
CASE WHEN pp.Diff3HomeGames > 0 THEN CAST(pp.Diff3HomePoints/pp.Diff3HomeGames AS DECIMAL(4,2)) ELSE 0 END AS D3HAvgPts,
CAST(pp.Diff3AwayPoints AS INT) AS D3APts,
pp.Diff3AwayGames AS D3AGames,
CASE WHEN pp.Diff3AwayGames > 0 THEN CAST(pp.Diff3AwayPoints/pp.Diff3AwayGames AS DECIMAL(4,2)) ELSE 0 END AS D3AAvgPts,
CASE WHEN pp.Diff4Games > 0 THEN CAST(pp.Diff4Points/pp.Diff4Games AS DECIMAL(4,2)) ELSE 0 END AS D4AvgPts,
CAST(pp.Diff4HomePoints AS INT) AS D4HPts,
pp.Diff4HomeGames AS D4HGames,
CASE WHEN pp.Diff4HomeGames > 0 THEN CAST(pp.Diff4HomePoints/pp.Diff4HomeGames AS DECIMAL(4,2)) ELSE 0 END AS D4HAvgPts,
CAST(pp.Diff4AwayPoints AS INT) AS D4APts,
pp.Diff4AwayGames AS D4AGames,
CASE WHEN pp.Diff4AwayGames > 0 THEN CAST(pp.Diff4AwayPoints/pp.Diff4AwayGames AS DECIMAL(4,2)) ELSE 0 END AS D4AAvgPts,
CASE WHEN pp.Diff5Games > 0 THEN CAST(pp.Diff5Points/pp.Diff5Games AS DECIMAL(4,2)) ELSE 0 END AS D5AvgPts,
CAST(pp.Diff5HomePoints AS INT) AS D5HPts,
pp.Diff5HomeGames AS D5HGames,
CASE WHEN pp.Diff5HomeGames > 0 THEN CAST(pp.Diff5HomePoints/pp.Diff5HomeGames AS DECIMAL(4,2)) ELSE 0 END AS D5HAvgPts,
CAST(pp.Diff5AwayPoints AS INT) AS D5APts,
pp.Diff5AwayGames AS D5AGames,
CASE WHEN pp.Diff5AwayGames > 0 THEN CAST(pp.Diff5AwayPoints/pp.Diff5AwayGames AS DECIMAL(4,2)) ELSE 0 END AS D5AAvgPts
FROM 
(
	SELECT dp.PlayerKey,
	MIN(dp.PlayerName) AS PlayerName,
	SUM(fph.TotalPoints * 1.00) AS TotalPoints,
	--AVG(fph.TotalPoints * 1.00) AS AvgPoints,
	SUM(CASE WHEN fph.[Minutes] > 0 THEN 1 ELSE 0 END) AS TotalGames,
	SUM(CASE WHEN fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS HomePoints,
	SUM(CASE WHEN fph.WasHome = 1 THEN 1 ELSE 0 END) AS HomeGames,
	AVG(CASE WHEN fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS AvgHomePoints,
	SUM(CASE WHEN fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS AwayPoints,
	SUM(CASE WHEN fph.WasHome = 0 THEN 1 ELSE 0 END) AS AwayGames,
	SUM(CASE WHEN fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS AvgAwayPoints,
	SUM(CASE WHEN dtd.Difficulty = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff1Points,
	SUM(CASE WHEN dtd.Difficulty = 1 THEN 1 ELSE 0 END) AS Diff1Games,
	SUM(CASE WHEN dtd.Difficulty = 1 AND fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff1HomePoints,
	SUM(CASE WHEN dtd.Difficulty = 1 AND fph.WasHome = 1 THEN 1 ELSE 0 END) AS Diff1HomeGames,
	SUM(CASE WHEN dtd.Difficulty = 1 AND fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff1AwayPoints,
	SUM(CASE WHEN dtd.Difficulty = 1 AND fph.WasHome = 0 THEN 1 ELSE 0 END) AS Diff1AwayGames,
	SUM(CASE WHEN dtd.Difficulty = 2 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff2Points,
	SUM(CASE WHEN dtd.Difficulty = 2 THEN 1 ELSE 0 END) AS Diff2Games,
	SUM(CASE WHEN dtd.Difficulty = 2 AND fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff2HomePoints,
	SUM(CASE WHEN dtd.Difficulty = 2 AND fph.WasHome = 1 THEN 1 ELSE 0 END) AS Diff2HomeGames,
	SUM(CASE WHEN dtd.Difficulty = 2 AND fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff2AwayPoints,
	SUM(CASE WHEN dtd.Difficulty = 2 AND fph.WasHome = 0 THEN 1 ELSE 0 END) AS Diff2AwayGames,
	SUM(CASE WHEN dtd.Difficulty = 3 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff3Points,
	SUM(CASE WHEN dtd.Difficulty = 3 THEN 1 ELSE 0 END) AS Diff3Games,
	SUM(CASE WHEN dtd.Difficulty = 3 AND fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff3HomePoints,
	SUM(CASE WHEN dtd.Difficulty = 3 AND fph.WasHome = 1 THEN 1 ELSE 0 END) AS Diff3HomeGames,
	SUM(CASE WHEN dtd.Difficulty = 3 AND fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff3AwayPoints,
	SUM(CASE WHEN dtd.Difficulty = 3 AND fph.WasHome = 0 THEN 1 ELSE 0 END) AS Diff3AwayGames,
	SUM(CASE WHEN dtd.Difficulty = 4 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff4Points,
	SUM(CASE WHEN dtd.Difficulty = 4 THEN 1 ELSE 0 END) AS Diff4Games,
	SUM(CASE WHEN dtd.Difficulty = 4 AND fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff4HomePoints,
	SUM(CASE WHEN dtd.Difficulty = 4 AND fph.WasHome = 1 THEN 1 ELSE 0 END) AS Diff4HomeGames,
	SUM(CASE WHEN dtd.Difficulty = 4 AND fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff4AwayPoints,
	SUM(CASE WHEN dtd.Difficulty = 4 AND fph.WasHome = 0 THEN 1 ELSE 0 END) AS Diff4AwayGames,
	SUM(CASE WHEN dtd.Difficulty = 5 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff5Points,
	SUM(CASE WHEN dtd.Difficulty = 5 THEN 1 ELSE 0 END) AS Diff5Games,
	SUM(CASE WHEN dtd.Difficulty = 5 AND fph.WasHome = 1 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff5HomePoints,
	SUM(CASE WHEN dtd.Difficulty = 5 AND fph.WasHome = 1 THEN 1 ELSE 0 END) AS Diff5HomeGames,
	SUM(CASE WHEN dtd.Difficulty = 5 AND fph.WasHome = 0 THEN fph.TotalPoints * 1.00 ELSE 0 END) AS Diff5AwayPoints,
	SUM(CASE WHEN dtd.Difficulty = 5 AND fph.WasHome = 0 THEN 1 ELSE 0 END) AS Diff5AwayGames
	FROM dbo.DimPlayer dp
	INNER JOIN dbo.FactPlayerHistory fph
	ON dp.PlayerKey = fph.PlayerKey
	AND fph.[Minutes] > 0
	INNER JOIN dbo.DimTeamDifficulty dtd
	ON fph.OpponentTeamKey = dtd.TeamKey
	AND fph.SeasonKey = dtd.SeasonKey
	AND fph.WasHome = dtd.IsOpponentHome
	--WHERE fph.[Minutes] > 0
	GROUP BY dp.PlayerKey
) pp
INNER JOIN dbo.DimPlayerAttribute dpa
ON pp.PlayerKey = dpa.PlayerKey
AND dpa.SeasonKey = 11
INNER JOIN dbo.DimPlayerPosition dpp
ON dpa.PlayerPositionKey = dpp.PlayerPositionKey;