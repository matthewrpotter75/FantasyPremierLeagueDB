CREATE PROCEDURE dbo.UserTeamClassicLeagueStagingTransfer
(
	@Increment INT = 10000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamClassicLeague
	DECLARE @i INT = 1;
	DECLARE @RowsInserted INT = 0;
	DECLARE @RowsDeleted INT = 1;
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

		--Delete UserTeamClassicLeagueStaging duplicate rows
		;WITH dups AS
		(
			SELECT userteamid, leagueid,
			ROW_NUMBER () OVER (PARTITION BY userteamid, leagueid ORDER BY userteamid, leagueid) AS RowNum
			FROM dbo.UserTeamClassicLeagueStaging WITH (NOLOCK)
		)
		DELETE st
		FROM dups st
		WHERE RowNum > 1
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate staging rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		--Delete UserTeamClassicLeagueStaging rows already on UserTeamClassicLeague
		DELETE st
		FROM dbo.UserTeamClassicLeagueStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamClassicLeague WITH (NOLOCK)
			WHERE leagueid = st.leagueid
			AND userteamid = st.userteamid
		)
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamClassicLeagueStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;

		SELECT @TotalRowsToBackfill = COUNT(*) 
		FROM dbo.UserTeamClassicLeagueStaging WITH (NOLOCK)
		OPTION (MAXDOP 1);

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN
	
			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			INSERT INTO dbo.UserTeamClassicLeague
			SELECT DISTINCT leagueid
					,entry_rank
					,entry_last_rank
					,entry_can_leave
					,entry_can_admin
					,entry_can_invite
					,userteamid
			FROM dbo.UserTeamClassicLeagueStaging st WITH (NOLOCK)
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
				FROM dbo.UserTeamClassicLeagueStaging st
				WHERE EXISTS
				(
					SELECT 1
					FROM #UserTeamIdsToProcess
					WHERE userteamid = st.userteamid
				)
				AND DateInserted < @StartTime
				OPTION (MAXDOP 1);

				SELECT @RowsDeleted = @@ROWCOUNT;
				SELECT @TotalRowsInserted = @TotalRowsInserted + @RowsInserted;
	
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