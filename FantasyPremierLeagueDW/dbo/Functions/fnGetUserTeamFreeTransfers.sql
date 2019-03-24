CREATE FUNCTION dbo.fnGetUserTeamFreeTransfers
(
	@SeasonKey INT,
	@UserTeamKey INT
)
RETURNS TABLE
AS
RETURN
(
	WITH TransferCount AS
	(
		SELECT 1 AS UserTeamKey,
		gw.SeasonKey,
		gw.GameweekKey,
		COUNT(pt.PlayerTransfersKey) As TransferCount,
		ISNULL(utc.ChipKey,0) AS ChipKey,
		ROW_NUMBER() OVER (ORDER BY gw.SeasonKey, gw.GameweekKey) AS iSequence
		FROM dbo.DimGameweek gw
		LEFT JOIN dbo.FactPlayerTransfers pt
		ON gw.SeasonKey = pt.SeasonKey
		AND pt.UserTeamKey = @UserTeamKey
		AND gw.GameweekKey = pt.GameweekKey
		LEFT JOIN dbo.DimUserTeamGameweekChip utc
		ON gw.SeasonKey = utc.SeasonKey
		AND gw.GameweekKey = utc.GameweekKey
		WHERE gw.SeasonKey = @SeasonKey
		GROUP BY gw.SeasonKey, gw.GameweekKey, utc.ChipKey
	),
	FreeTransfers AS
	(
		SELECT UserTeamKey,
		SeasonKey,
		GameweekKey,
		CASE
			WHEN TransferCount = 0 THEN 1
			ELSE 0
		END AS AvailableFreeTransfers,
		0 AS NumFreeTransfers,
		TransferCount,
		ChipKey,
		iSequence
		FROM TransferCount
		WHERE GameweekKey = 1

		UNION ALL

		SELECT ft.UserTeamKey,
		tc.SeasonKey,
		tc.GameweekKey,
		CASE
			WHEN tc.TransferCount = 0 THEN 1
			ELSE 0
		END AS AvailableFreeTransfers,
		CASE 
			WHEN tc.ChipKey IN (1,3) THEN tc.TransferCount --Wildcard or Free Hit
			WHEN ft.NumFreeTransfers < 2 THEN ft.NumFreeTransfers + ft.AvailableFreeTransfers
			WHEN ft.NumFreeTransfers >= 2 AND ft.TransferCount > 1 THEN 1
			ELSE ft.NumFreeTransfers
		END AS NumFreeTransfers,
		tc.TransferCount,
		tc.ChipKey,
		ft.iSequence + 1 AS iSequence
		FROM FreeTransfers ft
		INNER JOIN TransferCount tc
		ON ft.UserTeamKey = tc.UserTeamKey
		AND ft.iSequence = tc.iSequence - 1
		--ON ft.GameweekKey = tc.GameweekKey - 1
	)
	SELECT *,
	CASE
		WHEN TransferCount > NumFreeTransfers THEN (TransferCount - NumFreeTransfers) * 4
		ELSE 0
	END AS TransferCost
	FROM FreeTransfers
);