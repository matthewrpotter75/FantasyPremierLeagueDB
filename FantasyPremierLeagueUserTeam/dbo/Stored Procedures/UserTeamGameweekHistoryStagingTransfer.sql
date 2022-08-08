CREATE PROCEDURE dbo.UserTeamGameweekHistoryStagingTransfer
(
	@Increment INT = 20000,
	@DeleteIncrement INT = 500000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
WITH RECOMPILE
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamGameweekHistory
	DECLARE @i INT = 1;
	DECLARE @RowsInserted INT = 0;
	DECLARE @RowsUpdated INT = 0;
	DECLARE @RowsDeleted INT = 1;
	DECLARE @TotalRowsInserted INT = 0;
	DECLARE @TotalRowsDeleted INT = 0;
	DECLARE @TotalRowsProcessed INT = 0;
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

		SELECT @RowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate staging rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		SELECT @RowsDeleted = 1;

		--Delete existing rows
		WHILE @RowsDeleted > 0
		BEGIN

			--Delete UserTeamGameweekHistoryStaging rows already on UserTeamGameweekHistory
			DELETE TOP (@DeleteIncrement) st
			FROM dbo.UserTeamGameweekHistoryStaging st
			WHERE EXISTS
			(
				SELECT 1
				FROM dbo.UserTeamGameweekHistory WITH (NOLOCK)
				WHERE userteamid = st.userteamid
				AND gameweekid = st.gameweekid
			)
			OPTION (MAXDOP 1);

			SELECT @RowsDeleted = @@ROWCOUNT;
			SELECT @TotalRowsDeleted = @TotalRowsDeleted + @RowsDeleted;

			SELECT @Time = GETDATE();
			RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		END

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d total already existing rows deleted', 0, 1, @Time, @TotalRowsDeleted) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		SELECT @TotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamGameweekHistoryStaging WITH (NOLOCK) WHERE DateInserted < @StartTime;

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamGameweekHistoryStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;

		SELECT @RowsDeleted = 0;

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN

			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			UPDATE gh
			SET points = st.points,
			total_points = st.total_points,
			userteam_rank = st.userteam_rank,
			userteam_overall_rank = st.userteam_overall_rank,
			points_on_bench = st.points_on_bench,
			userteam_rank_sort = st.userteam_rank_sort
			FROM dbo.UserTeamGameweekHistory gh
			INNER JOIN dbo.UserTeamGameweekHistoryStaging st
			ON gh.userteamid = st.userteamid
			AND gh.gameweekid = st.gameweekid
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = st.userteamid
			)
			AND st.DateInserted < @StartTime
			AND gh.points <> st.points
			OPTION (MAXDOP 1);

			SELECT @RowsUpdated = @@ROWCOUNT;

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
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.UserTeamGameweekHistory WITH (NOLOCK)
				WHERE userteamid = st.userteamid
				AND gameweekid = st.gameweekid
			)
			AND DateInserted < @StartTime
			OPTION (MAXDOP 1);

			SELECT @RowsInserted = @@ROWCOUNT;
			SELECT @TotalRowsInserted = @TotalRowsInserted + @RowsInserted + @RowsUpdated;

			IF (@RowsInserted > 0 OR @RowsUpdated > 0)
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

				SELECT @RowsDeleted = @@ROWCOUNT;
				SELECT @TotalRowsProcessed = @TotalRowsProcessed + @RowsDeleted;

			END
			ELSE
			BEGIN

				SELECT @RowsDeleted = 0;

			END

			SELECT @Time = GETDATE();
			--RAISERROR('%s: Loop %d: %d rows inserted, %d rows updated, %d rows deleted (%d/%d)', 0, 1, @Time, @i, @RowsInserted, @RowsUpdated, @rowsDeleted, @TotalRowsProcessed, @TotalRowsToBackfill) WITH NOWAIT;
			RAISERROR('%s: Loop %d: %d rows inserted, %d rows updated, %d rows deleted (%d/%d)', 0, 1, @Time, @i, @RowsInserted, @RowsUpdated, @RowsDeleted, @TotalUserTeamsProcessed, @TotalUserTeams) WITH NOWAIT;

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
GO