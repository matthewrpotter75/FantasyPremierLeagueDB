CREATE PROCEDURE dbo.GetPlayerPricesChanges
(
	@Date DATETIME = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DateKey INT;

	IF @Date IS NOT NULL
	BEGIN

		SELECT @DateKey = DateKey FROM dbo.DimDate WHERE [Date] = CAST(@Date AS DATE);

		;WITH PrevCost AS
		(
			SELECT *, CAST(Cost AS SMALLINT) AS CostINT, LAG(Cost) OVER (PARTITION BY PlayerKey ORDER BY DateKey) AS PrevCost
			FROM dbo.FactPlayerDailyPrices
		)
		SELECT p.PlayerName, 
		t.TeamShortName AS Team,		
		pp.PlayerPositionShort AS PlayerPosition,
		d.DisplayDate,
		pc.Cost,
		pc.PrevCost AS PreviousCost,
		pc.CostINT - pc.PrevCost AS Change,
		CASE
			WHEN pc.Cost > pc.PrevCost THEN 'INC'
			ELSE 'DEC'
		END AS ChangeDirection
		FROM PrevCost pc
		INNER JOIN dbo.DimPlayer p
		ON pc.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimDate d
		ON pc.DateKey = d.DateKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = d.SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		WHERE Cost <> PrevCost
		AND pc.DateKey = @DateKey
		ORDER BY ChangeDirection, PlayerName, pc.DateKey;

	END
	ELSE
	BEGIN

		;WITH PrevCost AS
		(
			SELECT *, CAST(Cost AS SMALLINT) AS CostINT, LAG(Cost) OVER (PARTITION BY PlayerKey ORDER BY DateKey) AS PrevCost
			FROM dbo.FactPlayerDailyPrices
		)
		SELECT p.PlayerName, 
		t.TeamShortName AS Team,
		pp.PlayerPositionShort AS PlayerPosition,
		d.DisplayDate,
		pc.Cost,
		pc.PrevCost AS PreviousCost,
		pc.CostINT - pc.PrevCost AS Change,
		CASE
			WHEN pc.Cost > pc.PrevCost THEN 'INC'
			ELSE 'DEC'
		END AS ChangeDirection
		FROM PrevCost pc
		INNER JOIN dbo.DimPlayer p
		ON pc.PlayerKey = p.PlayerKey
		INNER JOIN dbo.DimDate d
		ON pc.DateKey = d.DateKey
		INNER JOIN dbo.DimPlayerAttribute pa
		ON p.PlayerKey = pa.PlayerKey
		AND pa.SeasonKey = d.SeasonKey
		INNER JOIN dbo.DimPlayerPosition pp
		ON pa.PlayerPositionKey = pp.PlayerPositionKey
		INNER JOIN dbo.DimTeam t
		ON pa.TeamKey = t.TeamKey
		WHERE Cost <> PrevCost
		ORDER BY pc.DateKey, ChangeDirection, PlayerName;

	END
END