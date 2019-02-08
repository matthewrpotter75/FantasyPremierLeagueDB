CREATE PROCEDURE dbo.SelectPotentialDuplicatePlayers
AS 
BEGIN

	SET XACT_ABORT ON;
	SET NOCOUNT ON;

	;WITH PlayerPosition AS
	(
		SELECT PlayerKey, MIN(PlayerPositionKey) AS PlayerPositionKey
		FROM dbo.DimPlayerAttribute
		GROUP BY PlayerKey
	)
	SELECT *
	FROM dbo.DimPlayer p
	INNER JOIN PlayerPosition pp
	ON p.PlayerKey = pp.PlayerKey
	WHERE EXISTS
	(
		SELECT FirstName, SecondName, WebName, PlayerName, COUNT(*)
		FROM dbo.DimPlayer
		WHERE FirstName = p.FirstName
		AND SecondName = p.SecondName
		GROUP BY FirstName, SecondName, WebName, PlayerName
		HAVING COUNT(*) > 1
	)
	ORDER BY FirstName,SecondName;

END