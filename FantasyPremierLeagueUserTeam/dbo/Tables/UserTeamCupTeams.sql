CREATE TABLE dbo.UserTeamCupTeams
(
	userteamcupid INT NOT NULL,
	userteamid INT NOT NULL,
	opponentuserteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	is_home BIT NOT NULL,
	is_winner BIT NOT NULL,
	CONSTRAINT PK_UserCupTeams PRIMARY KEY CLUSTERED (userteamcupid ASC,userteamid ASC)
)
GO


