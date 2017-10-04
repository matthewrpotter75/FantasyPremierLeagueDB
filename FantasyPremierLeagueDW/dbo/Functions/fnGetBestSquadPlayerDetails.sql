CREATE FUNCTION dbo.fnGetBestSquadPlayerDetails
(
	@SeasonKey INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT bts.*, pp.PlayerPositionShort, p.PlayerName, t.TeamName
	FROM dbo.BestTeamSquad bts
	INNER JOIN dbo.DimPlayer p
	ON bts.PlayerKey = p.PlayerKey
	INNER JOIN dbo.DimPlayerAttribute pa
	ON p.PlayerKey = pa.PlayerKey
	AND pa.SeasonKey = @SeasonKey
	INNER JOIN dbo.DimPlayerPosition pp
	ON pa.PlayerPositionKey = pp.PlayerPositionKey
	INNER JOIN dbo.DimTeam t
	ON pa.TeamKey = t.TeamKey
);