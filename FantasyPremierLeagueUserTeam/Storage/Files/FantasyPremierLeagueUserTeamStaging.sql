﻿/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
ADD FILE
(
	NAME = 'STAGING',
	FILENAME = '$(DefaultDataPath)$(DefaultFilePrefix)_FantasyPremierLeagueUserTeamStaging.ndf',
	SIZE=200MB,
	FILEGROWTH=200MB
)
TO FILEGROUP FantasyPremierLeagueUserTeamStaging
GO	
