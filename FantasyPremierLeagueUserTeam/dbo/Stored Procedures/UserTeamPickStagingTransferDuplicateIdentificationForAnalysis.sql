CREATE PROCEDURE dbo.UserTeamPickStagingTransferDuplicateIdentificationForAnalysis
AS
BEGIN

	SET NOCOUNT ON;

	--Insert UserTeamPickStaging dups into dup table for later inspection and then delete
	DECLARE @i INT = 1;
	DECLARE @RowsInserted INT = 0;
	DECLARE @RowsDeleted INT = 1;
	DECLARE @Time VARCHAR(30);
	DECLARE @ErrorMessage VARCHAR(500);

	BEGIN TRY

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
		WHERE EXISTS
		(
			SELECT 1
			FROM dups
			WHERE st.userteamid = dups.userteamid
			AND st.gameweekid = dups.gameweekid
			AND st.position = dups.position
		)
		OPTION (MAXDOP 1);

		SELECT @RowsInserted = @@ROWCOUNT;

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate rows inserted into dup table for later inspection', 0, 1, @Time, @RowsInserted) WITH NOWAIT;

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
		WHERE EXISTS
		(
			SELECT 1
			FROM dups
			WHERE st.userteamid = dups.userteamid
			AND st.gameweekid = dups.gameweekid
			AND st.position = dups.position
		)
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;

		SELECT @Time = GETDATE();
		RAISERROR('%s: %d duplicate rows deleted from UserTeamPickStaging table', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

	END TRY
	BEGIN CATCH

		SELECT @Time = GETDATE();
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR('%s: Error (dbo.UserTeamPickStagingTransferDuplicateIdentificationForAnalysis) - %s', 0, 1, @Time, @ErrorMessage) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;

		THROW;

	END CATCH

END
GO