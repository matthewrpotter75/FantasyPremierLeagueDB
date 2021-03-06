CREATE PROCEDURE dbo.GetPlayerPointsForPlayerPositionCostAfterStartGameweek
(
	@PlayerPositionKey INT = NULL,
	@SeasonKey INT = NULL,
	@StartGameweekKey INT = 1,
	@MaxCost INT = 1000,
	@MinutesCutoff INT = 0,
	@OrderBy VARCHAR(100) = 'TotalPointsAfterGameweek',
	@Debug TINYINT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF @Debug = 1
	BEGIN
		SELECT @PlayerPositionKey AS PlayerPositionKey, @SeasonKey AS SeasonKey, @StartGameweekKey AS StartGameweekKey, @MaxCost AS MaxCost, @OrderBy AS OrderBy;
	END

	IF @OrderBy = 'Cost'
	BEGIN

		SELECT *
		FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
		ORDER BY Cost DESC;

	END
	ELSE
	BEGIN
		IF @OrderBy = 'TotalPointsAfterGameweek'
		BEGIN

			SELECT *
			FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
			ORDER BY TotalPointsAfterGameweek DESC;

		END
		ELSE
		BEGIN
			IF @OrderBy = 'TotalPointsFullSeason'
			BEGIN

				SELECT *
				FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
				ORDER BY TotalPointsFullSeason DESC;

			END
			ELSE
			BEGIN
				IF @OrderBy = 'AvgPointsPerGameAfterGameweek'
				BEGIN

					SELECT *
					FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
					ORDER BY AvgPointsPerGameAfterGameweek DESC;

				END
				ELSE
				BEGIN
					IF @OrderBy = 'AvgPointsPerGameFullSeason'
					BEGIN

						SELECT *
						FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
						ORDER BY AvgPointsPerGameFullSeason DESC;

					END
					ELSE
					BEGIN
						IF @OrderBy = 'PointsAboveSeasonAvg'
						BEGIN

							SELECT *
							FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
							ORDER BY PointsAboveSeasonAvg DESC;

						END
						ELSE
						BEGIN
							IF @OrderBy = 'PercentagePointInGameweekRange'
							BEGIN

								SELECT *
								FROM dbo.fnGetPlayerPointsByPlayerPositionAfterSpecifiedGameweek(@PlayerPositionKey, @SeasonKey, @StartGameweekKey, @MinutesCutoff, @MaxCost)
								ORDER BY PercentagePointInGameweekRange DESC;

							END
						END
					END
				END
			END
		END
	END
END;