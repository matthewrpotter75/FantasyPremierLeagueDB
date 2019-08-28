CREATE TABLE dbo.UserTeamCupTiebreak
(
	userteamcupid INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
	tiebreak_name VARCHAR(20) NOT NULL,
	tiebreak_choice CHAR(1) NOT NULL,
	CONSTRAINT PK_UserTeamCupTiebreak PRIMARY KEY CLUSTERED (userteamcupid ASC)
);