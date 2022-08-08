CREATE PROCEDURE dbo.UserTeamPickStagingTransferDeleteDuplicates
(
	@Increment INT = 50000,
	@Delay VARCHAR(12) =  '00:00:10:000'
)
AS
BEGIN

	SET NOCOUNT ON;

	--Delete Duplicate rows on UserTeamPickStaging
	DECLARE @i INT = 1;
	DECLARE @RowsDeleted INT = 0;
	DECLARE @TotalRowsDeleted INT = 0;
	DECLARE @TotalRowsToBeDeleted INT = 0;
	DECLARE @Time VARCHAR(30);
	DECLARE @ErrorMessage VARCHAR(500);

	BEGIN TRY

		;WITH dups AS
		(
			SELECT userteamid, gameweekid, position, playerid,
			ROW_NUMBER () OVER (PARTITION BY userteamid, gameweekid, position ORDER BY DateInserted) AS RowNum
			FROM dbo.UserTeamPickStaging WITH (NOLOCK)
		)
		SELECT @TotalRowsToBeDeleted = COUNT(1)
		FROM dups st
		WHERE RowNum > 1
		OPTION (MAXDOP 1);

		IF @TotalRowsToBeDeleted > 0
		BEGIN

			WHILE @RowsDeleted > 0
			BEGIN

				;WITH dups AS
				(
					SELECT userteamid, gameweekid, position, playerid,
					ROW_NUMBER () OVER (PARTITION BY userteamid, gameweekid, position ORDER BY DateInserted) AS RowNum
					FROM dbo.UserTeamPickStaging WITH (NOLOCK)
				)
				DELETE TOP (@Increment) st
				FROM dups st
				WHERE RowNum > 1
				OPTION (MAXDOP 1);

				SET @RowsDeleted = @@ROWCOUNT;

				SELECT @time = CAST(GETDATE() AS VARCHAR(30));
				RAISERROR('%s: Loop %d: %d rows deleted (%d/%d)', 0, 1, @Time, @i, @RowsDeleted, @TotalRowsDeleted, @TotalRowsToBeDeleted) WITH NOWAIT;		

				SET @i = @i + 1;
				SELECT @TotalRowsDeleted = @TotalRowsDeleted + @RowsDeleted;

				WAITFOR DELAY @Delay;

			END

		END

		SELECT @Time = CAST(GETDATE() AS VARCHAR(30));
		RAISERROR('%s: %d total duplicate staging rows deleted', 0, 1, @Time, @TotalRowsDeleted) WITH NOWAIT;

	END TRY
	BEGIN CATCH

		SELECT @Time = GETDATE();
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR('%s: Error (dbo.UserTeamPickStagingTransferDeleteDuplicates) - %s', 0, 1, @Time, @ErrorMessage) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;

		THROW;

	END CATCH

END
GO