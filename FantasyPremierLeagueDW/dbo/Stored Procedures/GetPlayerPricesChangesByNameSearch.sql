CREATE PROCEDURE dbo.GetPlayerPricesChangesByNameSearch
(
	@PlayerSearchString VARCHAR(100),
	@SeasonKey INT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN

		SELECT @SeasonKey = SeasonKey
		FROM dbo.DimSeason
		WHERE SeasonStartDate < GETDATE()
		AND SeasonEndDate > GETDATE();

	END

	IF @PlayerSearchString IS NOT NULL
	BEGIN

		SELECT @PlayerSearchString = '%' + @PlayerSearchString + '%';

		;WITH PrevCost AS
		(
			SELECT *, CAST(Cost AS SMALLINT) AS CostINT, LAG(Cost) OVER (PARTITION BY PlayerKey ORDER BY DateKey) AS PrevCost
			FROM dbo.FactPlayerDailyPrices
		)
		SELECT p.PlayerName, 
		t.TeamShortName AS Team,		
		pp.PlayerPositionShort AS PlayerPosition,
		d.DisplayDate,
		pc.PrevCost AS PreviousCost,
		pc.Cost,		
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
		AND d.SeasonKey = @SeasonKey
		AND PATINDEX(@PlayerSearchString, p.PlayerName) > 0
		ORDER BY pc.PlayerKey, PlayerName, pc.DateKey;

	END

END
GO