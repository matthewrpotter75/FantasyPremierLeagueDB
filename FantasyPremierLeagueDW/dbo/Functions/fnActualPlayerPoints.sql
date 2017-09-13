CREATE FUNCTION dbo.fnActualPlayerPoints
(
	@SeasonKey INT,
	@PlayerPositionKey INT,
	@GameweekStart INT,
	@GameweekEnd INT
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
	AND pa.SeasonKey = @SeasonKey
	WHERE pa.PlayerPositionKey = @PlayerPositionKey
	AND ph.SeasonKey = @SeasonKey
	AND ph.GameweekKey BETWEEN @GameweekStart AND @GameweekEnd
	GROUP BY ph.PlayerKey, pa.PlayerPositionKey
);