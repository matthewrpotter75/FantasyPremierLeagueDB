CREATE PROCEDURE dbo.CopyDimChipSeasonChipKeysFromPreviousSeason
(
	@SeasonKey INT = NULL,
	@PreviousSeasonKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @PreviousSeasonKey IS NULL
	BEGIN
		SET @PreviousSeasonKey = @SeasonKey - 1;
	END
	
	IF @Debug = 0
	BEGIN

		INSERT INTO dbo.DimChipSeason
		(ChipKey, SeasonKey)
		SELECT ChipKey, @SeasonKey
		FROM dbo.DimChipSeason
		WHERE SeasonKey = @PreviousSeasonKey;

	END
	ELSE
	BEGIN

		SELECT ChipKey, @SeasonKey AS SeasonKey
		FROM dbo.DimChipSeason
		WHERE SeasonKey = @PreviousSeasonKey;

	END

END