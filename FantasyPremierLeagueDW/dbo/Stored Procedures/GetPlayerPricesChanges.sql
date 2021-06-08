CREATE PROCEDURE dbo.GetPlayerPricesChanges
(
	@Date DATETIME = NULL,
	@SeasonKey INT = NULL,
	@PriceChangeDirectionFilter VARCHAR(3) = NULL,
	@Debug BIT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DateKey INT;

	IF @SeasonKey IS NULL
	BEGIN

		SELECT @SeasonKey = SeasonKey
		FROM dbo.DimSeason
		WHERE SeasonStartDate < GETDATE()
		AND SeasonEndDate > GETDATE();

	END

	IF @Debug IS NOT NULL
	BEGIN
		SELECT @SeasonKey AS SeasonKey;
	END

	IF @Date IS NOT NULL
	BEGIN

		SELECT @DateKey = DateKey FROM dbo.DimDate WHERE [Date] = CAST(@Date AS DATE);

		IF @Debug IS NOT NULL
		BEGIN
			SELECT * FROM dbo.DimDate WHERE [Date] = CAST(@Date AS DATE);
		END

		;WITH PrevCost AS
		(
			SELECT fpdp.*, CAST(fpdp.Cost AS SMALLINT) AS CostINT, LAG(fpdp.Cost) OVER (PARTITION BY fpdp.PlayerKey ORDER BY fpdp.DateKey) AS PrevCost
			FROM dbo.FactPlayerDailyPrices fpdp
			INNER JOIN dbo.DimDate dd
			ON fpdp.DateKey = dd.DateKey
			WHERE dd.SeasonKey = @SeasonKey
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
		ORDER BY ChangeDirection DESC, PlayerName;

	END
	ELSE
	BEGIN

		;WITH PrevCost AS
		(
			SELECT pdp.*, CAST(Cost AS SMALLINT) AS CostINT, LAG(Cost) OVER (PARTITION BY PlayerKey ORDER BY pdp.DateKey) AS PrevCost
			FROM dbo.FactPlayerDailyPrices pdp
			INNER JOIN dbo.DimDate d
			ON pdp.DateKey = d.DateKey
			WHERE d.SeasonKey = @SeasonKey
		),
		Results AS
		(
			SELECT p.PlayerName, 
			t.TeamShortName AS Team,
			pp.PlayerPositionShort AS PlayerPosition,
			d.DateKey,
			d.DisplayDate,
			pc.Cost,
			pc.PrevCost AS PreviousCost,
			pc.CostINT - pc.PrevCost AS PriceChange,
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
			AND d.SeasonKey = @SeasonKey
		)
		SELECT PlayerName, 
			Team,
			PlayerPosition,
			DisplayDate,
			Cost,
			PreviousCost,
			PriceChange,
			ChangeDirection
		FROM Results
		WHERE 
		(
			ChangeDirection = @PriceChangeDirectionFilter
			OR
			ISNULL(@PriceChangeDirectionFilter,'') = ''
		)
		ORDER BY DateKey DESC, ChangeDirection DESC, PlayerName;

	END
END
GO