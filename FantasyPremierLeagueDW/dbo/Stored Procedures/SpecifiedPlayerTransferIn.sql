CREATE PROCEDURE dbo.SpecifiedPlayerTransferIn
(
	@SeasonKey INT = NULL,
	@SpecifiedPlayerKey INT,
	@PlayerToRemoveKey INT,
	@PlayersToChangeKeys VARCHAR(100),
	@GameweekStart INT,
	@GameweekEnd INT,
	@Overspend INT,
	@Debug BIT = 0,
	@TimerDebug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PlayerToChangeCost INT,
	@PlayerKeyToAdd INT,
	@PlayerToAddCost INT,
	@PlayerToAddPoints INT,
	@PlayerToAddName VARCHAR(100),
	@PlayerToChangeName VARCHAR(100),
	@SpecifiedPlayerCost INT,
	@SpecifiedPlayerTotalPoints INT,
	@PlayerToRemoveCost INT,
	@TotalCost INT,
	@Delimiter NVARCHAR(4) = ',',
	@time DATETIME;

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='SpecifiedPlayerTransferIn Starting', @Time=@time OUTPUT;
		SET @time = GETDATE();
	END

	DECLARE @PlayersToChangeTable TABLE (Id INT IDENTITY(1,1), PlayerKey INT, PlayerPositionKey INT, PlayerName VARCHAR(100), Cost INT, TotalPoints INT)

	INSERT INTO @PlayersToChangeTable
	(PlayerKey, PlayerPositionKey, PlayerName, Cost, TotalPoints)
	SELECT p.PlayerKey, pa.PlayerPositionKey, p.PlayerName, pcs.Cost, pcs.TotalPoints
	FROM dbo.fnSplit(@PlayersToChangeKeys, @Delimiter) sp
	INNER JOIN dbo.DimPlayer p
	ON sp.Term = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.FactPlayerCurrentStats pcs
	ON p.PlayerKey = pcs.PlayerKey;

	--Get current cost of player to be moved into the squad
	SELECT @SpecifiedPlayerCost = gws.Cost, @SpecifiedPlayerTotalPoints = gws.TotalPoints
	FROM dbo.FactPlayerGameweekStatus gws
	WHERE gws.PlayerKey = @SpecifiedPlayerKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd;

	--Get current cost of player to be moved out of the squad
	SELECT @PlayerToRemoveCost = gws.Cost
	FROM dbo.FactPlayerGameweekStatus gws
	WHERE gws.PlayerKey = @PlayerToRemoveKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd;

	IF @Debug=1
		SELECT @SpecifiedPlayerCost AS SpecifiedPlayerCost, @PlayerToRemoveCost AS PlayerToRemoveCost;

	--Initial update to transfer player in and one player out
	UPDATE cs
	SET PlayerKey = @SpecifiedPlayerKey, Cost = @SpecifiedPlayerCost, TotalPoints = @SpecifiedPlayerTotalPoints
	FROM #CurrentSquad cs
	INNER JOIN dbo.FactPlayerGameweekStatus gws
	ON cs.PlayerKey = gws.PlayerKey
	AND gws.SeasonKey = @SeasonKey
	AND gws.GameweekKey = @GameweekEnd
	WHERE cs.PlayerKey = @PlayerToRemoveKey;

	IF @TimerDebug = 1
	BEGIN
		EXEC dbo.OutputStepAndTimeText @Step='SpecifiedPlayerTransferIn Ending', @Time=@time OUTPUT;
	END

END