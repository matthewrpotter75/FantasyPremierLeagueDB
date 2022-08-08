CREATE PROCEDURE dbo.UserTeamPickAutomaticSubStagingTransfer
(
	@Increment INT = 10000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN

	SET NOCOUNT ON;

	--UserTeamPickAutomaticSub
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

	BEGIN TRY

		SELECT @Time = GETDATE();
		SELECT @StartTime = GETDATE();
		RAISERROR('%s: Starting...', 0, 1, @Time) WITH NOWAIT;

		--Delete UserTeamAutomaticSubStaging rows already on UserTeamPickAutomaticSub
		DELETE st
		FROM dbo.UserTeamPickAutomaticSubStaging st WITH (NOLOCK)
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamPickAutomaticSub WITH (NOLOCK)
			WHERE userteamid = st.userteamid
			AND gameweekid = st.gameweekid
			AND playerid_in = st.playerid_in
		)
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		SELECT @Time = GETDATE();
		RAISERROR('%s: Create IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid started', 0, 1, @Time) WITH NOWAIT;

		CREATE NONCLUSTERED INDEX IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid
		ON dbo.UserTeamPickAutomaticSubStaging (DateInserted)
		INCLUDE (playerid_in,playerid_out,userteamid,gameweekid);

		SELECT @Time = GETDATE();
		RAISERROR('%s: Create IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid completed', 0, 1, @Time) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamPickAutomaticSubStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;

		SELECT @TotalRowsToBackfill = COUNT(*) 
		FROM dbo.UserTeamPickAutomaticSubStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		OPTION (MAXDOP 1);

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN
	
			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			SELECT @TeamIncrementInserted = @@ROWCOUNT;

			INSERT INTO dbo.UserTeamPickAutomaticSub
			SELECT DISTINCT playerid_in
				  ,playerid_out
				  ,userteamid
				  ,gameweekid
			FROM dbo.UserTeamPickAutomaticSubStaging st WITH (NOLOCK)
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
				FROM dbo.UserTeamPickAutomaticSubStaging st WITH (NOLOCK)
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

			DELETE ut
			FROM #UserTeamIds ut
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = ut.userteamid
			);

			TRUNCATE TABLE #UserTeamIdsToProcess;

			SET @TotalUserTeamsProcessed = @TotalUserTeamsProcessed + @TeamIncrementInserted;

			SELECT @Time = GETDATE();
			RAISERROR('%s: Loop %d: %d rows inserted, %d rows deleted (%d/%d) Teams Processed (%d/%d)', 0, 1, @Time, @i, @RowsInserted, @RowsDeleted, @TotalRowsInserted, @TotalRowsToBackfill, @TotalUserTeamsProcessed, @TotalUserTeams) WITH NOWAIT;

			SET @i = @i + 1;

			WAITFOR DELAY @Delay;

		END

		SELECT @Time = GETDATE();
		RAISERROR('%s: Dropping IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid', 0, 1, @Time) WITH NOWAIT;

		DROP INDEX IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid
		ON dbo.UserTeamPickAutomaticSubStaging;

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

		SELECT @Time = GETDATE();
		RAISERROR('%s: Dropping IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid', 0, 1, @Time) WITH NOWAIT;

		IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.UserTeamPickAutomaticSubStaging') AND name = 'IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid')
			DROP INDEX IX_UserTeamPickAutomaticSubStaging_DateInserted_INC_playerid_in_playerid_out_userteamid_gameweekid
			ON dbo.UserTeamPickAutomaticSubStaging;

		THROW;

	END CATCH

END
GO