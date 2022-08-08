CREATE PROCEDURE dbo.UserTeamPickStagingTransferDeleteExistingRows
AS
BEGIN

	SET NOCOUNT ON;

	--Delete UserTeamPickStaging rows already on UserTeamPick
	DECLARE @RowsDeleted  INT = 0;
	DECLARE @Time VARCHAR(30);
	DECLARE @ErrorMessage VARCHAR(500);

	BEGIN TRY

		DELETE st
		FROM dbo.UserTeamPickStaging st WITH (NOLOCK)
		WHERE EXISTS
		(
			SELECT 1
			FROM dbo.UserTeamPick WITH (NOLOCK)
			WHERE userteamid = st.userteamid
			AND gameweekid = st.gameweekid
			AND position = st.position
		)
		OPTION (MAXDOP 1);

		SELECT @RowsDeleted = @@ROWCOUNT;

		SELECT @Time = CAST(GETDATE() AS VARCHAR(30));
		RAISERROR('%s: %d already existing rows deleted', 0, 1, @Time, @RowsDeleted) WITH NOWAIT;

	END TRY
	BEGIN CATCH

		SELECT @Time = GETDATE();
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR('%s: Error (dbo.UserTeamPickStagingTransferDeleteExistingRows)- %s', 0, 1, @Time, @ErrorMessage) WITH NOWAIT;
		RAISERROR(' ', 0, 1) WITH NOWAIT;

		THROW;

	END CATCH
END
GO