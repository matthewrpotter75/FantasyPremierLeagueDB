/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'PICKAUTOMATICSUB',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamPickAutomaticSub.ndf',
	SIZE=4000MB,
	FILEGROWTH=500MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamPickAutomaticSub
GO
	
