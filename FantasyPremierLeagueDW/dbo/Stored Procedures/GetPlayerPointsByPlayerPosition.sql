CREATE PROCEDURE dbo.GetPlayerPointsByPlayerPosition
(
	@PlayerPositionKey INT = NULL,
	@SeasonKey INT = NULL,
	@MaxCost INT = NULL,
	@OrderBy VARCHAR(20) = 'TotalPoints'
)
AS
BEGIN

	IF @OrderBy = 'Cost'
	BEGIN

		SELECT *
		FROM dbo.fnGetPlayerPointsByPlayerPosition(@PlayerPositionKey, @SeasonKey, @MaxCost)
		ORDER BY Cost DESC;

	END
	ELSE
	BEGIN

		SELECT *
		FROM dbo.fnGetPlayerPointsByPlayerPosition(@PlayerPositionKey, @SeasonKey, @MaxCost)
		ORDER BY TotalPoints DESC;

	END
END