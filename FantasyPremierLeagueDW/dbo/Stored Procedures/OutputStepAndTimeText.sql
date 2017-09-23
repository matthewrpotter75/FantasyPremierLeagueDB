CREATE PROCEDURE dbo.OutputStepAndTimeText
(
	@Step VARCHAR(50),
	@Time DATETIME = NULL OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @strTime CHAR(8), @Prevtime DATETIME, @Timediff VARCHAR(3);

	IF @Time IS NULL
	BEGIN

		SELECT @Time = GETDATE();
		SELECT @strTime = CONVERT(VARCHAR(30), @Time, 8);

		RAISERROR('%s %s', 0, 1, @Step, @strTime) WITH NOWAIT;
	
	END
	ELSE
	BEGIN
	
		SELECT @Prevtime = @Time
		SELECT @Time = GETDATE();
		SELECT @strTime = CONVERT(VARCHAR(30), @time, 8);
		SELECT @Timediff = CAST(DATEDIFF(second,@Prevtime,@Time) AS VARCHAR(3));
		RAISERROR('%s: %s (%s s)', 0, 1, @Step, @strTime, @Timediff) WITH NOWAIT;

	END

END