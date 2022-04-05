/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'TRANSFERHISTORY',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamTransferHistory.ndf',
	SIZE=1000MB,
	FILEGROWTH=500MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamTransferHistory
GO
