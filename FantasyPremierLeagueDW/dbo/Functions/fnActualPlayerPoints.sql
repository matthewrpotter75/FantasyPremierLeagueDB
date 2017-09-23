CREATE FUNCTION dbo.fnActualPlayerPoints
(
	@SeasonStartKey INT,
	@SeasonEndKey INT,
	@PlayerPositionKey INT,
	@GameweekStart INT,
	@GameweekEnd INT,
	@MinutesLimit INT = 0
)
RETURNS TABLE
AS
RETURN
(
	--Create temp table with actual points over the prediction period
	SELECT ph.PlayerKey,
	pa.PlayerPositionKey,
	SUM(ph.TotalPoints) AS ActualPoints,
	COUNT(ph.PlayerKey) AS ActualGames,
	SUM(ph.[Minutes]) AS ActualPlayerMinutes
	FROM dbo.FactPlayerHistory ph
	INNER JOIN dbo.DimPlayerAttribute pa
	ON ph.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonEndKey
	WHERE pa.PlayerPositionKey = @PlayerPositionKey
	AND 
	(
		(ph.SeasonKey = @SeasonStartKey AND ph.GameweekKey >= @GameweekStart)
		OR 
		(ph.SeasonKey = @SeasonEndKey AND ph.GameweekKey <= @GameweekEnd)
	)
	AND ph.[Minutes] >= @MinutesLimit
	GROUP BY ph.PlayerKey, pa.PlayerPositionKey
);