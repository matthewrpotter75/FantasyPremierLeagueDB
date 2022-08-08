CREATE TABLE dbo.UserTeamPickStagingInsert
(
    playerid        INT NOT NULL,
    position        INT NOT NULL,
    multiplier      INT NOT NULL,
    is_captain      BIT NOT NULL,
    is_vice_captain BIT NOT NULL,
    userteamid      INT NOT NULL,
    gameweekid      INT NOT NULL
	CONSTRAINT PK_UserTeamPickStagingInsert PRIMARY KEY CLUSTERED (userteamid ASC, gameweekid ASC, position ASC) 
    WITH (DATA_COMPRESSION = PAGE) 
    ON FantasyPremierLeagueUserTeamPickStaging
) 
ON FantasyPremierLeagueUserTeamPickStaging;
GO

--CREATE NONCLUSTERED INDEX [IX_UserTeamPickStagingInsert_userteamid_gameweekid_position]
    --ON [dbo].[UserTeamPickStagingInsert]([userteamid] ASC, [gameweekid] ASC, [position] ASC)
--ON [FantasyPremierLeagueUserTeamPick];;
GO