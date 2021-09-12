CREATE TABLE dbo.UserTeamChipStaging
(
	id INT IDENTITY(1,1) NOT NULL,
	chip_time SMALLDATETIME NOT NULL,
	chipid INT NOT NULL,
	userteamid INT NOT NULL,
	gameweekid INT NOT NULL,
)
ON FantasyPremierLeagueUserTeamStaging
GO


