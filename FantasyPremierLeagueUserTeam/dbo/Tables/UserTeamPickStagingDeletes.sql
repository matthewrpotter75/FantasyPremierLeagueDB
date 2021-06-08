CREATE TABLE [dbo].[UserTeamPickStagingDeletes] (
    [playerid]        INT NOT NULL,
    [position]        INT NOT NULL,
    [multiplier]      INT NOT NULL,
    [is_captain]      BIT NOT NULL,
    [is_vice_captain] BIT NOT NULL,
    [userteamid]      INT NOT NULL,
    [gameweekid]      INT NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_UserTeamPickStagingDeletes_userteamid_gameweekid_position]
    ON [dbo].[UserTeamPickStagingDeletes]([userteamid] ASC, [gameweekid] ASC, [position] ASC);

