CREATE TABLE dbo.UserTeamLeagueTeam
(
	leagueid INT NOT NULL,
	userteamid INT NOT NULL,
	CONSTRAINT PK_UserTeamLeagueTeam PRIMARY KEY CLUSTERED (leagueid ASC, userteamid ASC)
);