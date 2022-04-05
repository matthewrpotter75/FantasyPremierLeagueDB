CREATE PROCEDURE dbo.UserTeamSeasonStagingTransfer
(
	@Increment INT = 10000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--UserTeamSeason
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

		--Delete duplicates
		;WITH dups AS
		(
			SELECT *,
			ROW_NUMBER () OVER (PARTITION BY userteamid, season_name ORDER BY season_name) AS Rowcnt
			FROM dbo.UserTeamSeasonStaging WITH (NOLOCK)
		)
		DELETE
		FROM dups
		WHERE Rowcnt > 1
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;
		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate staging rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		--Delete UserTeamSeasonStaging rows already on UserTeamSeason
		DELETE st
		FROM dbo.UserTeamSeasonStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamSeason WITH (NOLOCK)
			WHERE userteamid = st.userteamid
			AND season_name = st.season_name
		)
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

		CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
		CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

		INSERT INTO #UserTeamIds
		SELECT DISTINCT userteamid
		FROM dbo.UserTeamSeasonStaging WITH (NOLOCK)
		WHERE DateInserted < @StartTime
		ORDER BY userteamid
		OPTION (MAXDOP 1);

		SELECT @TotalUserTeams = @@ROWCOUNT;
		SELECT @TotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamSeasonStaging WITH (NOLOCK);

		WHILE @TotalUserTeamsProcessed < @TotalUserTeams
		BEGIN
	
			INSERT INTO #UserTeamIdsToProcess
			SELECT TOP (@Increment) userteamid
			FROM #UserTeamIds
			ORDER BY userteamid;
	
			INSERT INTO dbo.UserTeamSeason
			SELECT DISTINCT st.userteamid
				  ,s.seasonid
				  ,st.total_points
				  ,st.userteam_rank
			FROM dbo.UserTeamSeasonStaging st WITH (NOLOCK)
			INNER JOIN dbo.Season s
			ON st.season_name = s.season_name
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
				FROM dbo.UserTeamSeasonStaging st
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