USE [msdb]
GO

/****** Object:  Job [UserTeamPickStaging to UserTeamPick Transfer]    Script Date: 22/02/2022 01:04:48 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 22/02/2022 01:04:48 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'UserTeamPickStaging to UserTeamPick Transfer', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete duplicates from UserTeamPickStaging]    Script Date: 22/02/2022 01:04:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete duplicates from UserTeamPickStaging', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Delete Duplicate rows on UserTeamPickStaging
SET NOCOUNT ON;

DECLARE @rowcnt INT = 1;
DECLARE @totalDuplicates INT = 0;
DECLARE @totalRowCnt INT = 0;
DECLARE @loop INT = 1;
DECLARE @time VARCHAR(30);

SELECT @time = CAST(GETDATE() AS VARCHAR(30));
RAISERROR(''%s: Starting...'', 10, 1, @time) WITH NOWAIT;
RAISERROR(''%s: Starting - Delete duplicates from UserTeamPickStaging'', 10, 1, @time) WITH NOWAIT;

;WITH dups AS
(
	SELECT userteamid, gameweekid, position, playerid,
	ROW_NUMBER () OVER (PARTITION BY userteamid, gameweekid, position ORDER BY DateInserted) AS RowNum
	FROM dbo.UserTeamPickStaging WITH (NOLOCK)
)
INSERT INTO dbo.UserTeamPickStagingExistingDeletes
SELECT DISTINCT userteamid, gameweekid, position
FROM dups st
WHERE RowNum > 1;

SELECT @totalDuplicates = @@ROWCOUNT;

SELECT @Time = GETDATE();
RAISERROR(''%s: Starting deletes (%d)'', 10, 1, @time, @totalDuplicates) WITH NOWAIT;

WHILE @totalRowCnt < @totalDuplicates
BEGIN

	;WITH dups AS
	(
		SELECT userteamid, gameweekid, position, playerid,
		ROW_NUMBER () OVER (PARTITION BY userteamid, gameweekid, position ORDER BY DateInserted) AS RowNum
		FROM dbo.UserTeamPickStaging WITH (NOLOCK)
	)
	DELETE TOP (100000) st
	FROM dups st
	WHERE RowNum > 1;

	SET @rowcnt = @@ROWCOUNT;

	SELECT @totalRowCnt = @totalRowCnt + @rowcnt;

	SELECT @time = CAST(GETDATE() AS VARCHAR(30));
	RAISERROR(''%s: Loop %d - %d rows deleted (%d/%d)'', 10, 1, @time, @loop, @rowcnt, @totalRowCnt, @totalDuplicates) WITH NOWAIT;
	SET @loop = @loop + 1;

END

TRUNCATE TABLE dbo.UserTeamPickStagingExistingDeletes;

SELECT @time = CAST(GETDATE() AS VARCHAR(30));
RAISERROR(''%s: Finished - Delete duplicates from UserTeamPickStaging'', 10, 1, @time) WITH NOWAIT;', 
		@database_name=N'FantasyPremierLeagueUserTeam202021', 
		@output_file_name=N'D:\Development\FantasyPremierLeagueLogs\UserTeamPickStaging to UserTeamPick Transfer\UserTeamPickStaging to UserTeamPick Transfer.log', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete UserTeamPickStaging rows already on UserTeamPick]    Script Date: 22/02/2022 01:04:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete UserTeamPickStaging rows already on UserTeamPick', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Delete UserTeamPickStaging rows on UserTeamPick
SET NOCOUNT ON;

DECLARE @rowcnt INT = 1;
DECLARE @totalExistingRows INT = 0;
DECLARE @totalRowCnt INT = 0;
DECLARE @loop INT = 1;
DECLARE @time VARCHAR(30);

SELECT @time = CAST(GETDATE() AS VARCHAR(30));
RAISERROR(''%s: Starting - Delete UserTeamPickStaging rows on UserTeamPick'', 10, 1, @time) WITH NOWAIT;

INSERT INTO dbo.UserTeamPickStagingExistingDeletes
SELECT DISTINCT userteamid, gameweekid, position
FROM dbo.UserTeamPickStaging st WITH (NOLOCK)
WHERE EXISTS
(
	SELECT 1
	FROM dbo.UserTeamPick WITH (NOLOCK)
	WHERE userteamid = st.userteamid
	AND gameweekid = st.gameweekid
	AND position = st.position
);

SELECT @totalExistingRows = @@ROWCOUNT;

SELECT @Time = GETDATE();
RAISERROR(''%s: Starting deletes (%d)'', 10, 1, @time, @totalExistingRows) WITH NOWAIT;

WHILE @totalRowCnt < @totalExistingRows
BEGIN

	DELETE TOP (10000) st
	FROM dbo.UserTeamPickStaging st
	WHERE EXISTS
	(
		 SELECT 1
		 FROM dbo.UserTeamPickStagingExistingDeletes WITH (NOLOCK)
		 WHERE userteamid = st.userteamid
		 AND gameweekid = st.gameweekid
		 AND position = st.position
	);

	SET @rowcnt = @@ROWCOUNT;

	SELECT @totalRowCnt = @totalRowCnt + @rowcnt;

	SELECT @time = CAST(GETDATE() AS VARCHAR(30));
	RAISERROR(''%s: Loop %d - %d rows deleted (%d/%d)'', 10, 1, @time, @loop, @rowcnt, @totalRowCnt, @totalExistingRows) WITH NOWAIT;
	SET @loop = @loop + 1;

END

TRUNCATE TABLE dbo.UserTeamPickStagingExistingDeletes;

SELECT @time = CAST(GETDATE() AS VARCHAR(30));
RAISERROR(''%s: Finished - Delete UserTeamPickStaging rows on UserTeamPick'', 10, 1, @time) WITH NOWAIT;', 
		@database_name=N'FantasyPremierLeagueUserTeam202021', 
		@output_file_name=N'D:\Development\FantasyPremierLeagueLogs\UserTeamPickStaging to UserTeamPick Transfer\UserTeamPickStaging to UserTeamPick Transfer.log', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Insert UserTeamPickStaging dups into dup table for later inspection and then delete]    Script Date: 22/02/2022 01:04:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insert UserTeamPickStaging dups into dup table for later inspection and then delete', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--UserTeamPickStaging rows to UserTeamPick transfer
SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @rowsInserted INT = 0;
DECLARE @rowsDeleted INT = 1;
DECLARE @TotalRowsInserted INT = 0;
DECLARE @TotalRowsToBackfill INT = 0;
DECLARE @NewTotalRowsToBackfill INT = 0;
DECLARE @PreviousTotalRowsToBackfill INT = 0;
DECLARE @Time VARCHAR(30);

SELECT @Time = GETDATE();
RAISERROR(''%s: Starting - Insert UserTeamPickStaging dups into dup table for later inspection and then delete'', 0, 1, @Time) WITH NOWAIT;

--Insert dups into dup table for later inspection
;WITH dups AS
(
	SELECT userteamid, gameweekid, position
	FROM dbo.UserTeamPickStaging WITH (NOLOCK)
	GROUP BY userteamid, gameweekid, position
	HAVING COUNT(*) > 1
)
INSERT INTO dbo.UserTeamPickStagingDups
SELECT st.*
FROM dbo.UserTeamPickStaging st WITH (NOLOCK)
INNER JOIN dups
ON st.userteamid = dups.userteamid
AND st.gameweekid = dups.gameweekid
AND st.position = dups.position;

SELECT @rowsInserted = @@ROWCOUNT;
SELECT @Time = GETDATE();
RAISERROR(''%s: %d duplicate rows inserted into dup table for later inspection'', 0, 1, @Time, @rowsInserted) WITH NOWAIT;
SELECT @rowsInserted = 0;

--Delete dups from staging table
;WITH dups AS
(
	SELECT userteamid, gameweekid, position
	FROM dbo.UserTeamPickStaging WITH (NOLOCK)
	GROUP BY userteamid, gameweekid, position
	HAVING COUNT(*) > 1
)
DELETE st
FROM dbo.UserTeamPickStaging st WITH (NOLOCK)
INNER JOIN dups
ON st.userteamid = dups.userteamid
AND st.gameweekid = dups.gameweekid
AND st.position = dups.position;

SELECT @rowsDeleted = @@ROWCOUNT;
SELECT @Time = GETDATE();
RAISERROR(''%s: %d duplicate rows deleted from UserTeamPickStaging table'', 0, 1, @Time, @rowsDeleted) WITH NOWAIT;

SELECT @time = CAST(GETDATE() AS VARCHAR(30));
RAISERROR(''%s: Finished - Insert UserTeamPickStaging dups into dup table for later inspection and then delete'', 10, 1, @time) WITH NOWAIT;

', 
		@database_name=N'FantasyPremierLeagueUserTeam202021', 
		@output_file_name=N'D:\Development\FantasyPremierLeagueLogs\UserTeamPickStaging to UserTeamPick Transfer\UserTeamPickStaging to UserTeamPick Transfer.log', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [UserTeamPickStaging to UserTeamPick transfer]    Script Date: 22/02/2022 01:04:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'UserTeamPickStaging to UserTeamPick transfer', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--UserTeamPickStaging rows to UserTeamPick transfer
SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @Increment INT = 10000;
DECLARE @rowsInserted INT = 0;
DECLARE @rowsDeleted INT = 1;
DECLARE @TotalRowsInserted INT = 0;
DECLARE @TotalRowsToBackfill INT = 0;
DECLARE @TotalUserTeams INT = 0;
DECLARE @TotalUserTeamsProcessed INT = 0;
--DECLARE @NewTotalRowsToBackfill INT = 0;
--DECLARE @PreviousTotalRowsToBackfill INT = 0;
DECLARE @Time VARCHAR(30);

SELECT @Time = GETDATE();
RAISERROR(''%s: Starting - UserTeamPickStaging rows to UserTeamPick transfer'', 0, 1, @Time) WITH NOWAIT;

CREATE TABLE #UserTeamIds (userteamid INT PRIMARY KEY);
CREATE TABLE #UserTeamIdsToProcess (userteamid INT PRIMARY KEY);

INSERT INTO #UserTeamIds
SELECT DISTINCT userteamid
FROM dbo.UserTeamPickStaging WITH (NOLOCK)
ORDER BY userteamid;

SELECT @TotalUserTeams = @@ROWCOUNT;

SELECT @TotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamPickStaging;
--SELECT @PreviousTotalRowsToBackfill = @NewTotalRowsToBackfill;

SELECT @Time = GETDATE();
RAISERROR(''%s: Starting inserts (%d)'', 10, 1, @time, @TotalRowsToBackfill) WITH NOWAIT;

RAISERROR(''%s: TotalUserTeamsProcessed/TotalUserTeams (%d/%d)'', 10, 1, @time, @TotalUserTeamsProcessed, @TotalUserTeams) WITH NOWAIT;

WHILE @TotalUserTeamsProcessed < @TotalUserTeams
BEGIN

	INSERT INTO #UserTeamIdsToProcess
	SELECT TOP (@Increment) userteamid
	FROM #UserTeamIds
	ORDER BY userteamid;

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
	);

	SELECT @rowsInserted = @@ROWCOUNT;

	IF @rowsInserted > 0
	BEGIN
	
		DELETE st
		FROM dbo.UserTeamPickStaging st
		WHERE EXISTS
		(
			SELECT 1
			FROM #UserTeamIdsToProcess
			WHERE userteamid = st.userteamid
		);

		SELECT @rowsDeleted = @@ROWCOUNT;

		SELECT @TotalRowsInserted = @TotalRowsInserted + @rowsInserted;

		--SELECT @NewTotalRowsToBackfill = COUNT(*) FROM dbo.UserTeamPickStaging WITH (NOLOCK);

		--IF (@TotalRowsToBackfill < @NewTotalRowsToBackfill + @rowsInserted)
		--BEGIN
		--	SELECT @TotalRowsToBackfill = @TotalRowsToBackfill + ((@NewTotalRowsToBackfill + @rowsInserted) - @TotalRowsToBackfill);
		--END

		--SELECT @PreviousTotalRowsToBackfill = @NewTotalRowsToBackfill;

	END
	ELSE
	BEGIN

		SELECT @rowsDeleted = 0;
		--SELECT @NewTotalRowsToBackfill = 0;

	END

	SELECT @Time = GETDATE();
	RAISERROR(''%s: Loop %d: %d rows inserted, %d rows deleted (%d/%d)'', 0, 1, @Time, @i, @rowsInserted, @rowsDeleted, @TotalRowsInserted, @TotalRowsToBackfill) WITH NOWAIT;

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

	WAITFOR DELAY ''00:00:30:000'';

END

SELECT @time = CAST(GETDATE() AS VARCHAR(30));

RAISERROR(''%s: Finished - UserTeamPickStaging rows to UserTeamPick transfer'', 0, 1, @Time) WITH NOWAIT;
RAISERROR(''%s: Completed'', 0, 1, @Time) WITH NOWAIT;

DROP TABLE #UserTeamIds;
DROP TABLE #UserTeamIdsToProcess;
GO', 
		@database_name=N'FantasyPremierLeagueUserTeam202021', 
		@output_file_name=N'D:\Development\FantasyPremierLeagueLogs\UserTeamPickStaging to UserTeamPick Transfer\UserTeamPickStaging to UserTeamPick Transfer.log', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'UserTeamPickStaging to UserTeamPick Transfer Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=6, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201012, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'f06460ec-26b3-49a9-9f76-7ab8e462cbbb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO