CREATE PROCEDURE dbo.UserTeamCupStagingTransfer
(
	@Increment INT = 10000,
	@DeleteIncrement INT = 500000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
WITH RECOMPILE
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamCup
	DECLARE @i INT = 1;
	DECLARE @RowsInserted INT = 0;
	DECLARE @RowsDeleted INT = 1;
	DECLARE @TotalRowsInserted INT = 0;
	DECLARE @TotalRowsDeleted INT = 0;
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

		DELETE
		FROM dbo.UserTeamCupStaging
		WHERE winner IS NULL
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d null winner UserTeamCupStaging matches deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		--Delete duplicates
		;WITH dups AS
		(
			SELECT *,
			ROW_NUMBER () OVER (PARTITION BY id, gameweekid, hometeam_userteamid, awayteam_userteamid ORDER BY winner DESC, fromuserteamid, hometeam_points DESC, awayteam_points DESC) AS Rowcnt
			FROM dbo.UserTeamCupStaging WITH (NOLOCK)
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

		--Delete UserTeamCupStaging rows already on UserTeamCup
			DELETE TOP (@DeleteIncrement) st
		FROM dbo.UserTeamCupStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamCup WITH (NOLOCK)
			WHERE id = st.id
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

		INSERT INTO #UserTeamIds
		SELECT DISTINCT fromuserteamid
		FROM dbo.UserTeamCupStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY fromuserteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;

		SELECT @TotalRowsToBackfill = COUNT(*) 
		FROM dbo.UserTeamCupStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = 0;

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN

			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;

			SELECT @TeamIncrementInserted = @@ROWCOUNT;

			INSERT INTO dbo.UserTeamCup
			SELECT DISTINCT id
				  ,homeTeam_userTeamid
				  ,homeTeam_userTeamName
				  ,homeTeam_PlayerName
				  ,awayTeam_userTeamid
				  ,awayTeam_userTeamName
				  ,awayTeam_PlayerName
				  ,is_knockout
				  ,winner
				  ,homeTeam_points
				  ,homeTeam_win
				  ,homeTeam_draw
				  ,homeTeam_loss
				  ,awayTeam_points
				  ,awayTeam_win
				  ,awayTeam_draw
				  ,awayTeam_loss
				  ,homeTeam_total
				  ,awayTeam_total
				  ,seed_value
				  ,league
				  ,gameweekid
				  ,fromuserteamid
				  ,tiebreak
			FROM dbo.UserTeamCupStaging st WITH (NOLOCK)
			WHERE EXISTS
			(
				SELECT 1
				FROM #UserTeamIdsToProcess
				WHERE userteamid = st.fromuserteamid
			)
			AND DateInserted < @StartTime
			OPTION (MAXDOP 1);

			SELECT @RowsInserted = @@ROWCOUNT;
			SELECT @TotalRowsInserted = @TotalRowsInserted + @RowsInserted;

			IF @RowsInserted > 0
			BEGIN

				DELETE st
				FROM dbo.UserTeamCupStaging st
				WHERE EXISTS
				(
					SELECT 1
					FROM #UserTeamIdsToProcess
					WHERE userteamid = st.fromuserteamid
				)
				AND DateInserted < @StartTime
				OPTION (MAXDOP 1);

				SELECT @RowsDeleted = @@ROWCOUNT;

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