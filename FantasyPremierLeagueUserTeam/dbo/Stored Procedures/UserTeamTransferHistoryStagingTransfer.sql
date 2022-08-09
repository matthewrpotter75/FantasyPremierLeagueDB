CREATE PROCEDURE dbo.UserTeamTransferHistoryStagingTransfer
(
	@Increment INT = 10000,
	@DeleteIncrement INT = 100000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
WITH RECOMPILE
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamTransferHistory
	DECLARE @i INT = 1;
	DECLARE @RowsInserted INT = 0;
	DECLARE @RowsDeleted INT = 1;
	DECLARE @TotalRowsInserted INT = 0;
	DECLARE @TotalRowsToBackfill INT = 0;
	DECLARE @TotalUserTeams INT = 0;
	DECLARE @TotalUserTeamsProcessed INT = 0;
	DECLARE @TotalExistingRowsDeleted INT = 0;
	DECLARE @ExistingRowsToBeDeleted INT = 0;
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
			ROW_NUMBER () OVER (PARTITION BY userteamid, gameweekid, playerid_in, playerid_out, transfer_time ORDER BY id) AS Rowcnt
			FROM dbo.UserTeamTransferHistoryStaging WITH (NOLOCK)
		)
		DELETE
		FROM dups
		WHERE Rowcnt > 1
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate staging rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		--IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = 'UserTeamTransferHistoryStaging' AND TABLE_SCHEMA = 'dbo')
		--BEGIN

		--	ALTER TABLE dbo.UserTeamTransferHistoryStaging ADD CONSTRAINT PK_UserTeamTransferHistoryStaging PRIMARY KEY CLUSTERED 
		--	(
		--		userteamid ASC,
		--		gameweekid ASC,
		--		playerid_in ASC,
		--		playerid_out ASC,
		--		transfer_time ASC
		--	) ON FantasyPremierLeagueUserTeamTransferHistory;

		--	SELECT @Time = GETDATE();
		--	RAISERROR('%s: PK_UserTeamTransferHistoryStaging created', 0, 1, @Time) WITH NOWAIT;

		--END

		SELECT @ExistingRowsToBeDeleted = COUNT(1)
		FROM dbo.UserTeamTransferHistoryStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamTransferHistory WITH (NOLOCK)
			WHERE userteamid = st.userteamid
			AND gameweekid = st.gameweekid
			AND playerid_in = st.playerid_in
			AND playerid_out = st.playerid_out
			AND transfer_time = st.transfer_time
		)
		OPTION (MAXDOP 1);

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d already existing rows to be deleted', 0, 1, @Time, @ExistingRowsToBeDeleted) WITH NOWAIT;

		SELECT @RowsDeleted = 1;

		--Delete UserTeamTransferHistoryStaging rows already on UserTeamTransferHistory
		WHILE @RowsDeleted > 0
		BEGIN

			DELETE TOP (@DeleteIncrement) st
			FROM dbo.UserTeamTransferHistoryStaging st
			WHERE EXISTS
			(
				SELECT 1
				FROM dbo.UserTeamTransferHistory WITH (NOLOCK)
				WHERE userteamid = st.userteamid
				AND gameweekid = st.gameweekid
				AND playerid_in = st.playerid_in
				AND playerid_out = st.playerid_out
				AND transfer_time = st.transfer_time
			)
			OPTION (MAXDOP 1);

			SELECT @RowsDeleted = @@ROWCOUNT;

			SELECT @TotalExistingRowsDeleted = @TotalExistingRowsDeleted + @RowsDeleted;

				SELECT @Time = GETDATE();
				RAISERROR('%s: Loop %d: %d already existing rows deleted', 0, 1, @Time, @i, @RowsDeleted) WITH NOWAIT;

			SET @i = @i + 1;

			WAITFOR DELAY @Delay;

		END

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d total already existing rows deleted', 0, 1, @Time, @TotalExistingRowsDeleted) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamTransferHistoryStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;

		SELECT @TotalRowsToBackfill = COUNT(*) 
		FROM dbo.UserTeamTransferHistoryStaging WITH (NOLOCK)
		OPTION (MAXDOP 1);

		SELECT @i = 1;
		SELECT @RowsDeleted = 0;

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN

			--SELECT @Time = GETDATE();
			--RAISERROR('%s: Loop %d: Insert starting...)', 0, 1, @Time, @i) WITH NOWAIT;
			
			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;
	
			INSERT INTO dbo.UserTeamTransferHistory
			SELECT userteamid
				  ,transfer_time
				  ,playerid_in
				  ,player_in_cost
				  ,playerid_out
				  ,player_out_cost
				  ,gameweekid
				  ,userteamtransferhistoryid
			FROM dbo.UserTeamTransferHistoryStaging st WITH (NOLOCK)
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = st.userteamid
			)
			AND DateInserted < @StartTime
			OPTION (MAXDOP 1);

			SELECT @RowsInserted = @@ROWCOUNT;
			SELECT @TotalRowsInserted = @TotalRowsInserted + @RowsInserted;

			--SELECT @Time = GETDATE();
			--RAISERROR('%s: Loop %d: Insert completed...)', 0, 1, @Time, @i) WITH NOWAIT;

			IF @RowsInserted > 0
			BEGIN

				--SELECT @Time = GETDATE();
				--RAISERROR('%s: Loop %d: Delete starting...)', 0, 1, @Time, @i) WITH NOWAIT;
				
				DELETE st
				FROM dbo.UserTeamTransferHistoryStaging st
				WHERE EXISTS
				(
					SELECT 1
					FROM #UserTeamIdsToProcess
					WHERE userteamid = st.userteamid
				)
				AND DateInserted < @StartTime
				OPTION (MAXDOP 1);

				SELECT @RowsDeleted = @@ROWCOUNT;

				--SELECT @Time = GETDATE();
				--RAISERROR('%s: Loop %d: Delete completed...)', 0, 1, @Time, @i) WITH NOWAIT;

			END
			ELSE
			BEGIN

				SELECT @RowsDeleted = 0;

			END

			SELECT @Time = GETDATE();
			RAISERROR('%s: Loop %d: %d rows inserted, %d rows deleted (%d/%d)', 0, 1, @Time, @i, @RowsInserted, @RowsDeleted, @TotalRowsInserted, @TotalRowsToBackfill) WITH NOWAIT;

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
			SET @TotalUserTeamsProcessed = @TotalUserTeamsProcessed + @Increment;

			WAITFOR DELAY @Delay;

		END

		--ALTER TABLE dbo.UserTeamTransferHistoryStaging DROP CONSTRAINT PK_UserTeamTransferHistoryStaging;

		--SELECT @Time = GETDATE();
		--RAISERROR('%s: PK_UserTeamTransferHistoryStaging deleted', 0, 1, @Time) WITH NOWAIT;

		SELECT @Time = GETDATE();
		RAISERROR('%s: Completed', 0, 1, @Time) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;

		DROP TABLE #UserTeamIds;
		DROP TABLE #UserTeamIdsToProcess;

	END TRY
	BEGIN CATCH

		SELECT @Time = GETDATE();
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR('%s: Error: %s', 0, 1, @Time, @ErrorMessage) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;
		
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = 'UserTeamTransferHistoryStaging' AND TABLE_SCHEMA = 'dbo')
			ALTER TABLE dbo.UserTeamTransferHistoryStaging DROP CONSTRAINT PK_UserTeamTransferHistoryStaging;

		THROW;

	END CATCH

END
GO