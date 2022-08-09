﻿/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = GAMEWEEKHISTORY,
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamGameweekHistory.ndf',
	SIZE=10000MB,
	FILEGROWTH=500MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamGameweekHistory
GO
	
