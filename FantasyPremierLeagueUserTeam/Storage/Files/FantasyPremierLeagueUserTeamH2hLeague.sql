/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'H2HLEAGUE',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamH2hLeague.ndf',
	SIZE=100MB,
	FILEGROWTH=50MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamH2hLeague
GO