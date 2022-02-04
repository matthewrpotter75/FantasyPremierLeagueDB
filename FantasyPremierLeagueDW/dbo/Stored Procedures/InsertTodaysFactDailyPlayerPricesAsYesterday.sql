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

	IF @Debug = 1
	BEGIN

		SELECT @todayDateKey AS todayDateKey, @yesterdayDateKey AS yesterdayDateKey;

	END

	BEGIN TRY

		IF EXISTS (SELECT 1 FROM dbo.FactPlayerDailyPrices WHERE DateKey <= @todayDateKey)
		BEGIN

			IF @Debug = 0
			BEGIN

				BEGIN TRAN;
			
				INSERT INTO dbo.FactPlayerDailyPrices
				(PlayerKey, TeamKey, DateKey, Cost)
				SELECT PlayerKey, TeamKey, @yesterdayDateKey AS DateKey, Cost
				FROM dbo.FactPlayerDailyPrices fdp
				WHERE DateKey = @todayDateKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimDate
					WHERE DateKey = fdp.DateKey
				);

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
				FROM dbo.FactPlayerDailyAttributes fda
				WHERE DateKey = @todayDateKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimDate
					WHERE DateKey = fda.DateKey
				);

				COMMIT TRAN;

			END
			ELSE
			BEGIN

				SELECT *
				FROM dbo.DimDate dd
				WHERE DateKey = @todayDateKey;
			
				SELECT PlayerKey, TeamKey, @yesterdayDateKey AS DateKey, Cost
				FROM dbo.FactPlayerDailyPrices fdp
				WHERE DateKey = @todayDateKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimDate
					WHERE DateKey = fdp.DateKey
				)
				ORDER BY PlayerKey;

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
				FROM dbo.FactPlayerDailyAttributes fda
				WHERE DateKey = @todayDateKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimDate
					WHERE DateKey = fda.DateKey
				)
				ORDER BY PlayerKey;

			END

		END

	END TRY
	BEGIN CATCH

		IF @@ERROR > 0
		BEGIN

			SELECT
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorState,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage;

		END

		ROLLBACK TRAN;

	END CATCH

END
GO