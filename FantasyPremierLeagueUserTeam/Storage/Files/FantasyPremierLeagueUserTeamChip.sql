/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'CHIP',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamChip.ndf',
	SIZE=1100MB,
	FILEGROWTH=100MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamChip
GO