CREATE PROCEDURE dbo.UserTeamPickStagingTransfer
(
	@Increment INT = 1000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN

	SET NOCOUNT ON;

	--UserTeamPickStaging rows to UserTeamPick transfer
	DECLARE @i INT = 1;
	DECLARE @RowsInserted INT = 0;
	DECLARE @RowsDeleted INT = 1;
	DECLARE @TotalRowsInserted INT = 0;
	DECLARE @TotalRowsToBackfill INT = 0;
	DECLARE @TeamIncrementInserted INT = 0;
	DECLARE @TotalUserTeams INT = 0;
	DECLARE @TotalUserTeamsProcessed INT = 0;
	DECLARE @Time VARCHAR(30);
	DECLARE @StartTime DATETIME;
	DECLARE @ErrorMessage VARCHAR(500);

	SELECT @Time = GETDATE();
	SELECT @StartTime = GETDATE();
	RAISERROR('%s: Starting...', 10, 1, @Time) WITH NOWAIT;

	--Delete Duplicate rows on UserTeamPickStaging
	EXEC dbo.UserTeamPickStagingTransferDeleteDuplicates;

	--Delete UserTeamPickStaging rows already on UserTeamPick
	EXEC dbo.UserTeamPickStagingTransferDeleteExistingRows;

	--Insert UserTeamPickStaging dups into dup table for later inspection and then delete
	EXEC dbo.UserTeamPickStagingTransferDuplicateIdentificationForAnalysis;

	BEGIN TRY

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamPickStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;

		SELECT @TotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamPickStaging OPTION (MAXDOP 1);
		--SELECT @PreviousTotalRowsToBackfill = @NewTotalRowsToBackfill;

		SELECT @Time = GETDATE();
		RAISERROR('%s: Starting inserts (%d)', 10, 1, @Time, @TotalRowsToBackfill) WITH NOWAIT;

		RAISERROR('%s: TotalUserTeamsProcessed/TotalUserTeams (%d/%d)', 10, 1, @Time, @TotalUserTeamsProcessed, @TotalUserTeams) WITH NOWAIT;

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN

			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			SELECT @TeamIncrementInserted = @@ROWCOUNT;

			INSERT INTO dbo.UserTeamPick
			SELECT DISTINCT playerid
				  ,position
				  ,multiplier
				  ,is_captain
				  ,is_vice_captain
				  ,userteamid
				  ,gameweekid
			FROM dbo.UserTeamPickStaging st WITH (NOLOCK)
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = st.userteamid
			)
			AND DateInserted < @StartTime
			OPTION (MAXDOP 1);

			SELECT @RowsInserted = @@ROWCOUNT;

			IF @RowsInserted > 0
			BEGIN
	
				DELETE st
				FROM dbo.UserTeamPickStaging st
				WHERE EXISTS
				(
					SELECT 1
					FROM #UserTeamIdsToProcess
					WHERE userteamid = st.userteamid
				)
				OPTION (MAXDOP 1);

				SELECT @RowsDeleted = @@ROWCOUNT;

				SELECT @TotalRowsInserted = @TotalRowsInserted + @RowsInserted;

			END
			ELSE
			BEGIN

				SELECT @RowsDeleted = 0;

			END

			SET @TotalUserTeamsProcessed = @TotalUserTeamsProcessed + @TeamIncrementInserted;

			SELECT @Time = GETDATE();
			RAISERROR('%s: Loop %d: %d rows inserted, %d rows deleted (%d/%d) - %d/%d teams processed', 0, 1, @Time, @i, @rowsInserted, @RowsDeleted, @TotalRowsInserted, @TotalRowsToBackfill, @TotalUserTeamsProcessed, @TotalUserTeams) WITH NOWAIT;

			DELETE ut
			FROM #UserTeamIds ut
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = ut.userteamid
			);

			TRUNCATE TABLE #UserTeamIdsToProcess
	
			SET @i = @i + 1;

			WAITFOR DELAY @Delay;

		END

		DROP TABLE #UserTeamIds;
		DROP TABLE #UserTeamIdsToProcess;

		SELECT @Time = CAST(GETDATE() AS VARCHAR(30));
		RAISERROR('%s: Completed', 0, 1, @Time) WITH NOWAIT;
		RAISERROR('', 0, 1) WITH NOWAIT;

	END TRY
	BEGIN CATCH

		SELECT @Time = GETDATE();
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR('%s: Error (dbo.UserTeamPickStagingTransfer) - %s', 0, 1, @Time, @ErrorMessage) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;

		THROW;

	END CATCH

END
GO