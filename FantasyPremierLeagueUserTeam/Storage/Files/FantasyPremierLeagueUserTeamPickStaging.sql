﻿/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'PICKSTAGING',
	FILENAME = '$(DefaultDataPath)FantasyPremierLeagueUserTeamPickStaging.ndf',
	SIZE=1400MB,
	FILEGROWTH=500MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamPickStaging
GO