CREATE PROCEDURE dbo.UserTeamGameweekHistoryStagingTransfer
(
	@Increment INT = 10000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamGameweekHistory
	DECLARE @i INT = 1;
	DECLARE @rowsInserted INT = 0;
	DECLARE @rowsDeleted INT = 1;
	DECLARE @TotalRowsInserted INT = 0;
	DECLARE @TotalRowsToBackfill INT = 0;
	DECLARE @TotalUserTeams INT = 0;
	DECLARE @TotalUserTeamsProcessed INT = 0;
	DECLARE @Time VARCHAR(30);
	DECLARE @StartTime DATETIME;
	DECLARE @ErrorMessage VARCHAR(500);

	BEGIN TRY

		SELECT @Time = GETDATE();
		SELECT @StartTime = GETDATE();
		RAISERROR('%s: Starting...', 0, 1, @Time) WITH NOWAIT;

		--Delete duplicates
		;WITH dups AS
		(
			SELECT *,
			ROW_NUMBER () OVER (PARTITION BY id, userteamid, gameweekid ORDER BY points DESC) AS Rowcnt
			FROM dbo.UserTeamGameweekHistoryStaging WITH (NOLOCK)
		)
		DELETE
		FROM dups
		WHERE Rowcnt > 1
		OPTION (MAXDOP 1);

		SELECT @rowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate staging rows deleted', 0, 1, @Time, @rowsDeleted) WITH NOWAIT;

		--Delete UserTeamGameweekHistoryStaging rows already on UserTeamGameweekHistory
		DELETE st
		FROM dbo.UserTeamGameweekHistoryStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamGameweekHistory WITH (NOLOCK)
			WHERE userteamid = st.userteamid
			AND gameweekid = st.gameweekid
		)
		OPTION (MAXDOP 1);

		SELECT @rowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @rowsDeleted) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamGameweekHistoryStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;
		SELECT @TotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamGameweekHistoryStaging WITH (NOLOCK);

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN

			;WITH dups AS
			(
				SELECT *,
				ROW_NUMBER () OVER (PARTITION BY id, userteamid, gameweekid ORDER BY points DESC) AS Rowcnt
				FROM dbo.UserTeamGameweekHistoryStaging WITH (NOLOCK)
			)
			DELETE
			FROM dups
			WHERE Rowcnt > 1
			OPTION (MAXDOP 1);

			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			INSERT INTO dbo.UserTeamGameweekHistory
			SELECT DISTINCT userteamid
				  ,gameweekid
				  ,points
				  ,total_points
				  ,userteam_rank
				  ,userteam_rank_sort
				  ,userteam_overall_rank
				  ,userteam_gameweek_transfers
				  ,userteam_gameweek_transfers_cost
				  ,userteam_bank
				  ,userteam_value
				  ,points_on_bench
			FROM dbo.UserTeamGameweekHistoryStaging st WITH (NOLOCK)
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = st.userteamid
			)
			AND DateInserted < @StartTime
			OPTION (MAXDOP 1);

			SELECT @rowsInserted = @@ROWCOUNT;

			IF @rowsInserted > 0
			BEGIN

				DELETE st
				FROM dbo.UserTeamGameweekHistoryStaging st
				WHERE EXISTS
				(
					SELECT 1
					FROM #UserTeamIdsToProcess
					WHERE userteamid = st.userteamid
				)
				AND DateInserted < @StartTime
				OPTION (MAXDOP 1);

				SELECT @rowsDeleted = @@ROWCOUNT;
				SELECT @TotalRowsInserted = @TotalRowsInserted + @rowsInserted;
				SELECT @Time = GETDATE();

			END
			ELSE
			BEGIN

				SELECT @rowsDeleted = 0;

			END

			RAISERROR('%s: Loop %d: %d rows inserted, %d rows deleted (%d/%d)', 0, 1, @Time, @i, @rowsInserted, @rowsDeleted, @TotalRowsInserted, @TotalRowsToBackfill) WITH NOWAIT;

			DELETE ut
			FROM #UserTeamIds ut
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = ut.userteamid
			);

			TRUNCATE TABLE #UserTeamIdsToProcess;

			SET @i = @i + 1;
			SET @TotalUserTeamsProcessed = @TotalUserTeamsProcessed + @Increment;

			WAITFOR DELAY @Delay;

		END

		SELECT @Time = GETDATE();
		RAISERROR('%s: Completed', 0, 1, @Time) WITH NOWAIT;
		RAISERROR('', 0, 1) WITH NOWAIT;

		DROP TABLE #UserTeamIds;
		DROP TABLE #UserTeamIdsToProcess;

	END TRY
	BEGIN CATCH

		SELECT @Time = GETDATE();
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR('%s: Error: %s', 0, 1, @Time, @ErrorMessage) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;

		THROW;

	END CATCH

END