CREATE PROCEDURE dbo.DeleteDuplicatePlayersByPlayerKey
(
	@DuplicatePlayerKey INT,
	@OriginalPlayerKey INT = 0,
	@Debug TINYINT = 0
)
AS 
BEGIN

	SET XACT_ABORT ON;
	SET NOCOUNT ON;

    DECLARE @error int,
            @message varchar(4000),
            @xstate int;

	DECLARE @DuplicatePlayerName VARCHAR(100),
			@OriginalPlayerName VARCHAR(100);

	BEGIN TRY

		SELECT @DuplicatePlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @DuplicatePlayerKey;
		SELECT @OriginalPlayerName = PlayerName FROM dbo.DimPlayer WHERE PlayerKey = @OriginalPlayerKey;

		SELECT @DuplicatePlayerName AS DuplicatePlayerName;
		SELECT @OriginalPlayerName AS OriginalPlayerName;

		IF @Debug = 0
		BEGIN

			IF @DuplicatePlayerName = @OriginalPlayerName
			OR PATINDEX(@DuplicatePlayerName, @OriginalPlayerName) > 0
			BEGIN

				BEGIN TRANSACTION;

				--FactPlayerHistory
				--Delete if there's a duplicate
				DELETE ph
				FROM dbo.FactPlayerHistory ph
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerHistory
					WHERE PlayerKey = @OriginalPlayerKey
					AND SeasonKey = ph.SeasonKey
					AND GameweekKey = ph.GameweekKey
					AND TotalPoints = ph.TotalPoints
					AND GameweekFixtureKey = ph.GameweekFixtureKey
					AND OpponentTeamKey = ph.OpponentTeamKey
				);

				PRINT 'FactPlayerHistory: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE ph
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.FactPlayerHistory ph
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerHistory
					WHERE PlayerKey = @OriginalPlayerKey
					AND SeasonKey = ph.SeasonKey
					AND GameweekKey = ph.GameweekKey
					AND TotalPoints = ph.TotalPoints
					AND GameweekFixtureKey = ph.GameweekFixtureKey
					AND OpponentTeamKey = ph.OpponentTeamKey
				);

				PRINT 'FactPlayerHistory: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';
			
				--DimPlayerAttribute
				--Delete if there's a duplicate
				DELETE pa
				FROM dbo.DimPlayerAttribute pa
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimPlayerAttribute
					WHERE PlayerKey = @OriginalPlayerKey
					AND TeamKey = pa.TeamKey
				);

				PRINT 'DimPlayerAttribute: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE pa
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.DimPlayerAttribute pa
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.DimPlayerAttribute
					WHERE PlayerKey = @OriginalPlayerKey
					AND TeamKey = pa.TeamKey
				);

				PRINT 'DimPlayerAttribute: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';

				--DimPlayerSeason
				--Delete if there's a duplicate
				DELETE ps
				FROM dbo.DimPlayerSeason ps
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimPlayerSeason
					WHERE PlayerKey = @OriginalPlayerKey
					AND PlayerId = ps.PlayerId
					AND SeasonKey = ps.SeasonKey
				);

				PRINT 'DimPlayerSeason: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE ps
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.DimPlayerSeason ps
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.DimPlayerSeason
					WHERE PlayerKey = @OriginalPlayerKey
					AND PlayerId = ps.PlayerId
					AND SeasonKey = ps.SeasonKey
				);

				PRINT 'DimPlayerAttribute: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';

				--DimPlayerTeamGameweekFixture
				DELETE ptgf
				FROM dbo.DimPlayerTeamGameweekFixture ptgf
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.DimPlayerTeamGameweekFixture
					WHERE PlayerKey = @OriginalPlayerKey
					AND TeamKey = ptgf.TeamKey
					AND GameweekKey = ptgf.GameweekKey
					AND SeasonKey = ptgf.SeasonKey
					AND GameweekFixtureKey = ptgf.GameweekFixtureKey
					AND IsHome = ptgf.IsHome
				);

				PRINT 'DimPlayerTeamGameweekFixture: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--FactPlayerCurrentStats
				DELETE fpcs
				FROM dbo.FactPlayerCurrentStats fpcs
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerCurrentStats
					WHERE PlayerKey = @OriginalPlayerKey
				);

				PRINT 'FactPlayerCurrentStats: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--FactPlayerDailyPrices
				--Delete if there's a duplicate
				DELETE fpdp
				FROM dbo.FactPlayerDailyPrices fpdp
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerDailyPrices
					WHERE PlayerKey = @OriginalPlayerKey
					AND DateKey = fpdp.DateKey
					AND TeamKey = fpdp.TeamKey
					AND Cost = fpdp.Cost
				);

				PRINT 'FactPlayerDailyPrices: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE fpdp
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.FactPlayerDailyPrices fpdp
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerDailyPrices
					WHERE PlayerKey = @DuplicatePlayerKey
					AND DateKey = fpdp.DateKey
					AND TeamKey = fpdp.TeamKey
					AND Cost = fpdp.Cost
				);

				PRINT 'FactPlayerDailyPrices: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';

				--FactPlayerGameweekNews
				--Delete if there's a duplicate
				DELETE pgn
				FROM dbo.FactPlayerGameweekNews pgn
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerGameweekNews
					WHERE PlayerKey = @OriginalPlayerKey
					AND TeamKey = pgn.TeamKey
					AND SeasonKey = pgn.SeasonKey
					AND GameweekKey = pgn.GameweekKey
					AND PlayerNewsKey = pgn.PlayerNewsKey
				);

				PRINT 'FactPlayerGameweekNews: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE pgn
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.FactPlayerGameweekNews pgn
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerGameweekNews
					WHERE PlayerKey = @OriginalPlayerKey
					AND TeamKey = pgn.TeamKey
					AND SeasonKey = pgn.SeasonKey
					AND GameweekKey = pgn.GameweekKey
					AND PlayerNewsKey = pgn.PlayerNewsKey
				);

				PRINT 'FactPlayerGameweekNews: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';

				--FactPlayerGameweekStatus
				--Delete if there's a duplicate
				DELETE pgs
				FROM dbo.FactPlayerGameweekStatus pgs
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerGameweekStatus
					WHERE PlayerKey = @OriginalPlayerKey
					AND SeasonKey = pgs.SeasonKey
					AND GameweekKey = pgs.GameweekKey
					AND TeamKey = pgs.TeamKey
					AND Cost = pgs.Cost
				);

				PRINT 'FactPlayerGameweekStatus: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE pgs
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.FactPlayerGameweekStatus pgs
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerGameweekStatus
					WHERE PlayerKey = @OriginalPlayerKey
					AND SeasonKey = pgs.SeasonKey
					AND GameweekKey = pgs.GameweekKey
					AND TeamKey = pgs.TeamKey
					AND Cost = pgs.Cost
				);

				PRINT 'FactPlayerGameweekStatus: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';

				--FactPlayerHistoryPastSeasons
				--Delete if there's a duplicate
				DELETE phps
				FROM dbo.FactPlayerHistoryPastSeasons phps
				WHERE PlayerKey = @DuplicatePlayerKey
				AND EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerHistoryPastSeasons
					WHERE PlayerKey = @OriginalPlayerKey
					AND SeasonKey = phps.SeasonKey
					AND TotalPoints = phps.TotalPoints
				);

				PRINT 'FactPlayerHistoryPastSeasons: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				--Update to original player key if no entry for original
				UPDATE phps
				SET PlayerKey = @OriginalPlayerKey
				FROM dbo.FactPlayerHistoryPastSeasons phps
				WHERE PlayerKey = @DuplicatePlayerKey
				AND NOT EXISTS
				(
					SELECT 1
					FROM dbo.FactPlayerHistoryPastSeasons
					WHERE PlayerKey = @OriginalPlayerKey
					AND SeasonKey = phps.SeasonKey
					AND TotalPoints = phps.TotalPoints
				);

				PRINT 'FactPlayerHistoryPastSeasons: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows updated';

				--DimPlayer
				DELETE
				FROM dbo.DimPlayer
				WHERE PlayerKey = @DuplicatePlayerKey;

				PRINT 'DimPlayer: ' + CAST(@@ROWCOUNT AS VARCHAR(5)) + ' rows deleted';

				COMMIT TRANSACTION;

			END
		END
		ELSE
		BEGIN

			SELECT 'dbo.FactPlayerHistory';
		
			SELECT *
			FROM dbo.FactPlayerHistory
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerHistory rows to be deleted';

			SELECT *
			FROM dbo.FactPlayerHistory ph
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerHistory
				WHERE PlayerKey = @OriginalPlayerKey
				AND SeasonKey = ph.SeasonKey
				AND GameweekKey = ph.GameweekKey
				AND TotalPoints = ph.TotalPoints
				AND GameweekFixtureKey = ph.GameweekFixtureKey
				AND OpponentTeamKey = ph.OpponentTeamKey
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerHistory rows to be updated';

			SELECT @OriginalPlayerKey AS NewPlayerKey,*
			FROM dbo.FactPlayerHistory ph
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerHistory
				WHERE PlayerKey = @OriginalPlayerKey
				AND SeasonKey = ph.SeasonKey
				AND GameweekKey = ph.GameweekKey
				AND TotalPoints = ph.TotalPoints
				AND GameweekFixtureKey = ph.GameweekFixtureKey
				AND OpponentTeamKey = ph.OpponentTeamKey
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.DimPlayerAttribute';
		
			SELECT *
			FROM dbo.DimPlayerAttribute
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayerAttribute rows to be deleted';
		
			SELECT *
			FROM dbo.DimPlayerAttribute pa
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.DimPlayerAttribute
				WHERE PlayerKey = @OriginalPlayerKey
				AND TeamKey = pa.TeamKey
			)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayerAttribute rows to be updated';

			SELECT @OriginalPlayerKey AS NewPlayerKey, *
			FROM dbo.DimPlayerAttribute pa
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.DimPlayerAttribute
				WHERE PlayerKey = @OriginalPlayerKey
				AND TeamKey = pa.TeamKey
			)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayerSeason';

			SELECT *
			FROM dbo.DimPlayerSeason
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayerSeason rows to be deleted';

			SELECT *
			FROM dbo.DimPlayerSeason ps
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.DimPlayerSeason
				WHERE PlayerKey = @OriginalPlayerKey
				AND PlayerId = ps.PlayerId
				AND SeasonKey = ps.SeasonKey
			)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayerSeason rows to be updated';

			SELECT @OriginalPlayerKey AS NewPlayerKey, *
			FROM dbo.DimPlayerSeason ps
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.DimPlayerSeason
				WHERE PlayerKey = @OriginalPlayerKey
				AND PlayerId = ps.PlayerId
				AND SeasonKey = ps.SeasonKey
			)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayerTeamGameweekFixture';
		
			SELECT *
			FROM dbo.DimPlayerTeamGameweekFixture
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.DimPlayerTeamGameweekFixture rows to be deleted';
		
			SELECT *			
			FROM dbo.DimPlayerTeamGameweekFixture ptgf
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.DimPlayerTeamGameweekFixture
				WHERE PlayerKey = @OriginalPlayerKey
				AND TeamKey = ptgf.TeamKey
				AND GameweekKey = ptgf.GameweekKey
				AND SeasonKey = ptgf.SeasonKey
				AND GameweekFixtureKey = ptgf.GameweekFixtureKey
				AND IsHome = ptgf.IsHome
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;
		
			SELECT 'dbo.FactPlayerCurrentStats';
		
			SELECT *
			FROM dbo.FactPlayerCurrentStats
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey);

			SELECT 'dbo.FactPlayerCurrentStats row to be deleted';
		
			SELECT *
			FROM dbo.FactPlayerCurrentStats fpcs
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerCurrentStats
				WHERE PlayerKey = @OriginalPlayerKey
			)
			ORDER BY PlayerKey;

			SELECT 'dbo.FactPlayerDailyPrices';
		
			SELECT *
			FROM dbo.FactPlayerDailyPrices
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY DateKey, PlayerKey;

			SELECT 'dbo.FactPlayerDailyPrices rows to be deleted';
		
			SELECT *
			FROM dbo.FactPlayerDailyPrices fpdp
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerDailyPrices
				WHERE PlayerKey = @OriginalPlayerKey
				AND DateKey = fpdp.DateKey
				AND TeamKey = fpdp.TeamKey
				AND Cost = fpdp.Cost
			)
			ORDER BY DateKey, PlayerKey;

			SELECT 'dbo.FactPlayerDailyPrices rows to be deleted';
		
			SELECT @OriginalPlayerKey AS UpdatedPlayerKey,*
			FROM dbo.FactPlayerDailyPrices fpdp
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerDailyPrices
				WHERE PlayerKey = @DuplicatePlayerKey
				AND DateKey = fpdp.DateKey
				AND TeamKey = fpdp.TeamKey
				AND Cost = fpdp.Cost
			)
			ORDER BY DateKey, PlayerKey;

			SELECT 'dbo.FactPlayerGameweekNews';
		
			SELECT *
			FROM dbo.FactPlayerGameweekNews
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerGameweekNews to be deleted';
		
			SELECT *
			FROM dbo.FactPlayerGameweekNews pgn
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerGameweekNews
				WHERE PlayerKey = @OriginalPlayerKey
				AND TeamKey = pgn.TeamKey
				AND SeasonKey = pgn.SeasonKey
				AND GameweekKey = pgn.GameweekKey
				AND PlayerNewsKey = pgn.PlayerNewsKey
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerGameweekNews to be updated';
		
			SELECT @OriginalPlayerKey AS NewPlayerKey,*
			FROM dbo.FactPlayerGameweekNews pgn
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerGameweekNews
				WHERE PlayerKey = @OriginalPlayerKey
				AND TeamKey = pgn.TeamKey
				AND SeasonKey = pgn.SeasonKey
				AND GameweekKey = pgn.GameweekKey
				AND PlayerNewsKey = pgn.PlayerNewsKey
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerGameweekStatus';
		
			SELECT *
			FROM dbo.FactPlayerGameweekStatus
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerGameweekStatus rows to be deleted';
		
			SELECT *
			FROM dbo.FactPlayerGameweekStatus pgs
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerGameweekStatus
				WHERE PlayerKey = @OriginalPlayerKey
				AND SeasonKey = pgs.SeasonKey
				AND GameweekKey = pgs.GameweekKey
				AND TeamKey = pgs.TeamKey
				AND Cost = pgs.Cost
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerGameweekStatus rows to be updated';
		
			SELECT @OriginalPlayerKey AS NewPlayerKey,*
			FROM dbo.FactPlayerGameweekStatus pgs
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerGameweekStatus
				WHERE PlayerKey = @OriginalPlayerKey
				AND SeasonKey = pgs.SeasonKey
				AND GameweekKey = pgs.GameweekKey
				AND TeamKey = pgs.TeamKey
				AND Cost = pgs.Cost
			)
			ORDER BY SeasonKey, GameweekKey, PlayerKey;

			SELECT 'dbo.FactPlayerHistoryPastSeasons';
		
			SELECT *
			FROM dbo.FactPlayerHistoryPastSeasons
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.FactPlayerHistoryPastSeasons rows to be deleted';

			SELECT *
			FROM dbo.FactPlayerHistoryPastSeasons phps
			WHERE PlayerKey = @DuplicatePlayerKey
			AND EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerHistoryPastSeasons
				WHERE PlayerKey = @OriginalPlayerKey
				AND SeasonKey = phps.SeasonKey
				AND TotalPoints = phps.TotalPoints
			)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.FactPlayerHistoryPastSeasons rows to be updated';

			SELECT @OriginalPlayerKey AS NewPlayerKey,*
			FROM dbo.FactPlayerHistoryPastSeasons phps
			WHERE PlayerKey = @DuplicatePlayerKey
			AND NOT EXISTS
			(
				SELECT 1
				FROM dbo.FactPlayerHistoryPastSeasons
				WHERE PlayerKey = @OriginalPlayerKey
				AND SeasonKey = phps.SeasonKey
				AND TotalPoints = phps.TotalPoints
			)
			ORDER BY SeasonKey, PlayerKey;

			SELECT 'dbo.DimPlayer';
		
			SELECT *
			FROM dbo.DimPlayer
			WHERE PlayerKey IN (@DuplicatePlayerKey,@OriginalPlayerKey);

		END

	END TRY
	BEGIN CATCH

		SELECT
		  @error = ERROR_NUMBER(),
		  @message = ERROR_MESSAGE(),
		  @xstate = XACT_STATE();

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		RAISERROR ('DeleteDuplicatePlayersByPlayerKey error: %d: %s', 16, 1, @error, @message);

    END CATCH

END