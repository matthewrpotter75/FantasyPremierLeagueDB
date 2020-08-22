CREATE PROCEDURE dbo.InsertTodaysFactDailyPlayerPricesAsYesterday
(
	@todayDate DATE = NULL,
	@debug TINYINT = 0
)
AS
BEGIN

	DECLARE @todayDateKey INT,
	@yesterdayDateKey INT,
	@maxDateKey INT;

	SELECT @todayDate = ISNULL(@todayDate, CAST(GETDATE() AS DATE));
	
	SELECT @todayDateKey = DateKey
	FROM dbo.DimDate
	WHERE [Date] = @todayDate;

	SELECT @yesterdayDateKey = @todayDateKey - 1;

	IF EXISTS (SELECT 1 FROM dbo.FactPlayerDailyPrices WHERE DateKey <= @todayDateKey)
	BEGIN

		IF @Debug = 0
		BEGIN

			INSERT INTO dbo.FactPlayerDailyPrices
			(PlayerKey, TeamKey, DateKey, Cost)
			SELECT PlayerKey, TeamKey, @yesterdayDateKey AS DateKey, Cost
			FROM dbo.FactPlayerDailyPrices
			WHERE DateKey = @todayDateKey;

			INSERT INTO dbo.FactPlayerDailyAttributes
			SELECT PlayerKey
			  ,@yesterdayDateKey AS DateKey
			  ,ChanceOfPlayingThisRound
			  ,ChanceOfPlayingNextRound
			  ,ValueForm
			  ,ValueSeason
			  ,CostChangeStart
			  ,CostChangeEvent
			  ,CostChangeStartFall
			  ,CostChangeEventFall
			  ,InDreamteam
			  ,DreamteamCount
			  ,SelectedByPercent
			  ,Form
			  ,TransfersOut
			  ,TransfersIn
			  ,TransfersOutEvent
			  ,TransfersInEvent
			  ,LoansIn
			  ,LoansOut
			  ,LoanedIn
			  ,LoanedOut
			  ,TotalPoints
			  ,EventPoints
			  ,PointsPerGame
			  ,ExpectedPointsThis
			  ,ExpectedPointsNext
			  ,Influence
			  ,Creativity
			  ,Threat
			  ,ICT_Index
			  ,EA_Index
			FROM dbo.FactPlayerDailyAttributes
			WHERE DateKey = @todayDateKey;

			--INSERT INTO dbo.FactPlayerDailyAttributes
			--SELECT PlayerKey, 2053 AS DateKey, ChanceOfPlayingThisRound, ChanceOfPlayingNextRound, ValueForm, ValueSeason, CostChangeStart, CostChangeEvent, CostChangeStartFall, CostChangeEventFall, InDreamteam, DreamteamCount, SelectedByPercent, Form, TransfersOut, TransfersIn,
			--TransfersOutEvent, TransfersInEvent, LoansIn, LoansOut, LoanedIn, LoanedOut, TotalPoints, EventPoints, PointsPerGame, ExpectedPointsThis, ExpectedPointsNext, Influence, Creativity, Threat, ICT_Index, EA_Index
			--FROM dbo.FactPlayerDailyAttributes
			--WHERE DateKey = 2052

		END
		ELSE
		BEGIN

			SELECT PlayerKey, TeamKey, @yesterdayDateKey AS DateKey, Cost
			FROM dbo.FactPlayerDailyPrices
			WHERE DateKey = @todayDateKey;

			SELECT PlayerKey
			  ,@yesterdayDateKey AS DateKey
			  ,ChanceOfPlayingThisRound
			  ,ChanceOfPlayingNextRound
			  ,ValueForm
			  ,ValueSeason
			  ,CostChangeStart
			  ,CostChangeEvent
			  ,CostChangeStartFall
			  ,CostChangeEventFall
			  ,InDreamteam
			  ,DreamteamCount
			  ,SelectedByPercent
			  ,Form
			  ,TransfersOut
			  ,TransfersIn
			  ,TransfersOutEvent
			  ,TransfersInEvent
			  ,LoansIn
			  ,LoansOut
			  ,LoanedIn
			  ,LoanedOut
			  ,TotalPoints
			  ,EventPoints
			  ,PointsPerGame
			  ,ExpectedPointsThis
			  ,ExpectedPointsNext
			  ,Influence
			  ,Creativity
			  ,Threat
			  ,ICT_Index
			  ,EA_Index
			FROM dbo.FactPlayerDailyAttributes
			WHERE DateKey = @todayDateKey;

		END

	END
END
GO