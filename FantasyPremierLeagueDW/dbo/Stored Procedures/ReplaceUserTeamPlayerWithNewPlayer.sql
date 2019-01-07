CREATE PROCEDURE dbo.ReplaceUserTeamPlayerWithNewPlayer
(
	@UserTeamKey INT = NULL,
	@UserTeamName VARCHAR(100) = NULL,
	@SeasonKey INT = NULL,
	@NextGameweekKey INT = NULL,
	@PlayerName VARCHAR(100) = NULL,
	@NewPlayerName VARCHAR(100) = NULL,
	@PlayerKey INT = NULL,
	@NewPlayerKey INT = NULL,
	@Debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PlayerTransferredOutCost INT, @PlayerTransferredInCost INT;
	DECLARE @DateKey INT;

	IF @SeasonKey IS NULL
	BEGIN
		SELECT @SeasonKey = SeasonKey FROM dbo.DimSeason WHERE GETDATE() BETWEEN SeasonStartDate AND SeasonEndDate;
	END

	IF @NextGameweekKey IS NULL
	BEGIN
		SET @NextGameweekKey = (SELECT TOP (1) GameweekKey FROM dbo.DimGameweek WHERE DeadlineTime > GETDATE() ORDER BY DeadlineTime);
	END

	IF @UserTeamName IS NOT NULL
	BEGIN
		SELECT @UserTeamKey = UserTeamKey FROM dbo.DimUserTeam WHERE UserTeamName = @UserTeamName;
	END

	IF @UserTeamKey IS NOT NULL
	BEGIN

		IF @PlayerKey IS NULL OR @NewPlayerKey IS NULL
		BEGIN

			SELECT @PlayerKey = PlayerKey
			FROM dbo.DimPlayer
			WHERE PlayerName = @PlayerName;

			SELECT @NewPlayerKey = PlayerKey
			FROM dbo.DimPlayer
			WHERE PlayerName = @NewPlayerName;

		END

		IF (@PlayerName IS NULL AND @NewPlayerName IS NULL)
		AND (@PlayerKey IS NOT NULL AND @NewPlayerKey IS NOT NULL)
		BEGIN

			SELECT @PlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @PlayerKey
			SELECT @NewPlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @NewPlayerKey

		END


		IF @PlayerKey IS NOT NULL AND @NewPlayerKey IS NOT NULL
		BEGIN

			SELECT @DateKey = MAX(DateKey)
			FROM dbo.DimDate
			WHERE SeasonKey = @SeasonKey
			AND GameweekKey = @NextGameweekKey;
			
			SELECT @PlayerTransferredOutCost = Cost FROM dbo.FactPlayerDailyPrices WHERE PlayerKey = @PlayerKey AND DateKey = @DateKey;
			SELECT @PlayerTransferredInCost = Cost FROM dbo.FactPlayerDailyPrices WHERE PlayerKey = @NewPlayerKey AND DateKey = @DateKey;

			IF @Debug = 1
				SELECT @SeasonKey AS SeasonKey, @NextGameweekKey AS NextGameweekKey, @DateKey AS DateKey, @PlayerTransferredOutCost AS PlayerTransferredOutCost, @PlayerTransferredInCost AS PlayerTransferredInCost;

			IF @PlayerTransferredOutCost IS NOT NULL AND @PlayerTransferredInCost IS NOT NULL AND @DateKey IS NOT NULL
			BEGIN

				UPDATE utp
				SET PlayerKey = @NewPlayerKey, Cost = pdp.Cost
				FROM dbo.DimUserTeamPlayer utp
				INNER JOIN dbo.FactPlayerDailyPrices pdp
				ON utp.PlayerKey = pdp.PlayerKey
				AND pdp.DateKey = @DateKey
				WHERE utp.UserTeamKey = @UserTeamKey
				AND utp.SeasonKey = @SeasonKey
				AND utp.GameweekKey = @NextGameweekKey
				AND utp.PlayerKey = @PlayerKey;

				IF @@ROWCOUNT > 0
				BEGIN
					PRINT 'Transfer completed: ' + @PlayerName + ' out, ' + @NewPlayerName + ' in (gameweek: ' + CAST(@NextGameweekKey AS VARCHAR(2)) + ')';

					INSERT INTO dbo.FactPlayerTransfers
					(UserTeamKey, SeasonKey, GameweekKey, PlayerTransferredOutKey, PlayerTransferredInKey, PlayerTransferredOutCost, PlayerTransferredInCost)
					VALUES (@UserTeamKey, @SeasonKey, @NextGameweekKey, @PlayerKey, @NewPlayerKey, @PlayerTransferredOutCost, @PlayerTransferredInCost);

				END
			END
			ELSE
			BEGIN
				PRINT 'No update performed';
			END

		END
		ELSE
		BEGIN
		
			IF @PlayerKey IS NULL
				PRINT 'Player: ' + @PlayerName + ' not found';

			IF @NewPlayerKey IS NULL
				PRINT 'New Player: ' + @NewPlayerName + ' not found';

		END

	END
	ELSE
	BEGIN

		RAISERROR('UserTeamKey is null. Check supplied UserTeamKey or UserTeamName!!!' , 0, 1) WITH NOWAIT;

	END

END