/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'PICK',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamPick.ndf',
	SIZE=50000MB,
	FILEGROWTH=500MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamPick
GO