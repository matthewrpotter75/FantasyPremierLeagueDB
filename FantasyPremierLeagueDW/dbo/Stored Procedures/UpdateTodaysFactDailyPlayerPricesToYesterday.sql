CREATE PROCEDURE dbo.UpdateTodaysFactDailyPlayerPricesToYesterday
AS
BEGIN

	DECLARE @todayDateKey INT,
	@yesterdayDateKey INT,
	@maxDateKey INT;

	SELECT @todayDateKey = DateKey
	FROM dbo.DimDate
	WHERE CAST(GETDATE() AS DATE) = [Date];

	SELECT @yesterdayDateKey = @todayDateKey - 1;

	IF EXISTS (SELECT 1 FROM dbo.FactPlayerDailyPrices WHERE DateKey <= @todayDateKey)
	BEGIN

		SELECT @maxDateKey = MAX(DateKey)
		FROM dbo.FactPlayerDailyPrices
		WHERE DateKey <= @todayDateKey

		UPDATE dbo.FactPlayerDailyPrices
		SET DateKey = @yesterdayDateKey
		WHERE DateKey = @todayDateKey;

		--INSERT INTO dbo.FactPlayerDailyPrices
		--SELECT PlayerKey, TeamKey, 2087 AS DateKey, Cost
		--FROM dbo.FactPlayerDailyPrices
		--WHERE DateKey = 2088

		UPDATE dbo.FactPlayerDailyAttributes
		SET DateKey = @yesterdayDateKey
		WHERE DateKey = @todayDateKey;

		--INSERT INTO dbo.FactPlayerDailyAttributes
		--SELECT PlayerKey, 2053 AS DateKey, ChanceOfPlayingThisRound, ChanceOfPlayingNextRound, ValueForm, ValueSeason, CostChangeStart, CostChangeEvent, CostChangeStartFall, CostChangeEventFall, InDreamteam, DreamteamCount, SelectedByPercent, Form, TransfersOut, TransfersIn,
		--TransfersOutEvent, TransfersInEvent, LoansIn, LoansOut, LoanedIn, LoanedOut, TotalPoints, EventPoints, PointsPerGame, ExpectedPointsThis, ExpectedPointsNext, Influence, Creativity, Threat, ICT_Index, EA_Index
		--FROM dbo.FactPlayerDailyAttributes
		--WHERE DateKey = 2052

	END
END
GO