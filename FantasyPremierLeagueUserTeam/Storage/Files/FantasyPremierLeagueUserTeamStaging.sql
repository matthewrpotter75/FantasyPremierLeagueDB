/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'STAGING',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamStaging.ndf',
	SIZE=500MB,
	FILEGROWTH=200MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamStaging
GO	
