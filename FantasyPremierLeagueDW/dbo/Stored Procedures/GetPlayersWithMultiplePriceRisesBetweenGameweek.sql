CREATE PROCEDURE dbo.GetPlayersWithMultiplePriceRisesBetweenGameweek
(
	@GameweekKey INT,
	@SeasonKey INT,
	@PriceRiseCutoff INT = 2,
	@IsFromSeasonStart BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @EndGameweekKey INT,
			@StartDate DATE,
			@EndDate DATE,
			@StartDateKey INT,
			@EndDateKey INT;

	SELECT @EndGameweekKey = @GameweekKey + 1;

	IF @IsFromSeasonStart = 0
	BEGIN
		SELECT @StartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE GameweekKey = @GameweekKey AND SeasonKey = @SeasonKey;
	END
	ELSE
	BEGIN
		SELECT @StartDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE GameweekKey = 1 AND SeasonKey = @SeasonKey;
	END

	SELECT @EndDate = CAST(DeadlineTime AS DATE) FROM dbo.DimGameweek WHERE GameweekKey = @EndGameweekKey AND SeasonKey = @SeasonKey;
	
	SELECT @StartDateKey = DateKey FROM dbo.DimDate WHERE [Date] = @StartDate;
	SELECT @EndDateKey = DateKey FROM dbo.DimDate WHERE [Date] = @EndDate;

	IF NOT EXISTS 
	(
		SELECT 1 
		FROM dbo.FactPlayerDailyPrices
		WHERE DateKey = @EndDateKey
	)
	BEGIN

		SELECT @EndDateKey = MAX(fpdp.DateKey)
		FROM dbo.FactPlayerDailyPrices fpdp
		INNER JOIN dbo.DimDate d
		ON fpdp.DateKey = d.DateKey
		WHERE d.SeasonKey = @SeasonKey

	END

	;WITH StartPlayerCost AS
	(
		SELECT PlayerKey,
		CAST(Cost AS INT) AS StartCost
		FROM dbo.FactPlayerDailyPrices
		WHERE DateKey = @StartDateKey
	),
	EndPlayerCost AS
	(
		SELECT PlayerKey,
		CAST(Cost AS INT) AS EndCost
		FROM dbo.FactPlayerDailyPrices
		WHERE DateKey = @EndDateKey
	)
	SELECT p.PlayerKey, p.PlayerName, spc.StartCost, epc.EndCost, epc.EndCost - spc.StartCost AS PriceChange
	FROM StartPlayerCost spc
	INNER JOIN EndPlayerCost epc
	ON spc.PlayerKey = epc.PlayerKey
	INNER JOIN dbo.DimPlayer p
	ON spc.PlayerKey = p.PlayerKey
	WHERE EndCost - StartCost >= @PriceRiseCutoff;

END
GO


