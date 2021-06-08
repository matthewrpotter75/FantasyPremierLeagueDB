CREATE TABLE [dbo].[UserTeamPickStagingWithDups] (
    [playerid]        INT NOT NULL,
    [position]        INT NOT NULL,
    [multiplier]      INT NOT NULL,
    [is_captain]      BIT NOT NULL,
    [is_vice_captain] BIT NOT NULL,
    [userteamid]      INT NOT NULL,
    [gameweekid]      INT NOT NULL
);

