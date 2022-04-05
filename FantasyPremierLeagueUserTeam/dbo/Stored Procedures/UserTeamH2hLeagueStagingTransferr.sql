CREATE PROCEDURE dbo.UserTeamH2hLeagueStagingTransfer
(
	@Increment INT = 10000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamH2hLeague
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

		--Delete UserTeamH2hLeagueStaging duplicate rows
		;WITH dups AS
		(
			SELECT userteamid, leagueid,
			ROW_NUMBER () OVER (PARTITION BY userteamid, leagueid ORDER BY userteamid, leagueid) AS RowNum
			FROM dbo.UserTeamH2hLeagueStaging WITH (NOLOCK)
		)
		DELETE st
		FROM dups st
		WHERE RowNum > 1;

		SELECT @rowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate staging rows deleted', 0, 1, @Time, @rowsDeleted) WITH NOWAIT;

		--Delete UserTeamH2hLeagueStaging rows already on UserTeamH2hLeague
		DELETE st
		--SELECT COUNT(*)
		FROM dbo.UserTeamH2hLeagueStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamH2hLeague WITH (NOLOCK)
			WHERE leagueid = st.leagueid
			AND userteamid = st.userteamid
		)
		OPTION (MAXDOP 1);

		SELECT @rowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @rowsDeleted) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamH2hLeagueStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;
		SELECT @TotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamH2hLeagueStaging WITH (NOLOCK);

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN

			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			INSERT INTO dbo.UserTeamH2hLeague
			SELECT DISTINCT leagueid
				  ,entry_rank
				  ,entry_last_rank
				  ,entry_can_leave
				  ,entry_can_admin
				  ,entry_can_invite
				  ,userteamid
			FROM dbo.UserTeamH2hLeagueStaging st WITH (NOLOCK)
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

				--Delete UserTeamH2hLeagueStaging rows already on UserTeamH2hLeague
				DELETE st
				FROM dbo.UserTeamH2hLeagueStaging st
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

			END
			ELSE
			BEGIN

				SELECT @rowsDeleted = 0;
				--SELECT @NewTotalRowsToBackfill = 0;

			END
	
			SELECT @Time = GETDATE();
			RAISERROR('%s: Loop %d: %d rows inserted, %d rows deleted (%d/%d)', 0, 1, @Time, @i, @rowsInserted, @rowsDeleted, @TotalRowsInserted, @TotalRowsToBackfill) WITH NOWAIT;

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