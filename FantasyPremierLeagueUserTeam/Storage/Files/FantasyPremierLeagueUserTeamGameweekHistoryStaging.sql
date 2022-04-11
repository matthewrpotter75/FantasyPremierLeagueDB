/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = GAMEWEEKHISTORYSTAGING,
		FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamGameweekHistoryStaging.ndf',
		SIZE=500MB,
		FILEGROWTH=100MB
	)
	TO FILEGROUP FantasyPremierLeagueUserTeamGameweekHistoryStaging
GO
	
