CREATE TABLE dbo.UserTeamPickAutomaticSubStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	playerid_in INT NOT NULL,
	playerid_out INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL
)
ON FantasyPremierLeagueUserTeamStaging
GO


