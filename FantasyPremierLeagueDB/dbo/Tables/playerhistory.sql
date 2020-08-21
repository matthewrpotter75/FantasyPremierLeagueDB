CREATE TABLE [dbo].[PlayerHistory] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [playerId]          INT            NOT NULL,
    [fixtureId]         INT            NOT NULL,
    [opponent_teamId]   INT            NOT NULL,
    [total_points]      SMALLINT       NOT NULL,
    [was_home]          BIT            NOT NULL,
    [kickoff_time]      SMALLDATETIME  NOT NULL,
    [team_h_score]      TINYINT        NULL,
    [team_a_score]      TINYINT        NULL,
    [gameweekId]        INT            NOT NULL,
    [minutes]           INT            NOT NULL,
    [goals_scored]      TINYINT        NOT NULL,
    [assists]           TINYINT        NOT NULL,
    [clean_sheets]      TINYINT        NOT NULL,
    [goals_conceded]    TINYINT        NOT NULL,
    [own_goals]         TINYINT        NOT NULL,
    [penalties_saved]   TINYINT        NOT NULL,
    [penalties_missed]  TINYINT        NOT NULL,
    [yellow_cards]      TINYINT        NOT NULL,
    [red_cards]         TINYINT        NOT NULL,
    [saves]             TINYINT        NOT NULL,
    [bonus]             TINYINT        NOT NULL,
    [bps]               SMALLINT       NOT NULL,
    [influence]         DECIMAL (6, 2) NOT NULL,
    [creativity]        DECIMAL (6, 2) NOT NULL,
    [threat]            DECIMAL (6, 2) NOT NULL,
    [ict_index]         DECIMAL (6, 2) NOT NULL,
    [value]             TINYINT        NOT NULL,
    [transfers_balance] INT            NOT NULL,
    [selected]          INT            NOT NULL,
    [transfers_in]      INT            NOT NULL,
    [transfers_out]     INT            NOT NULL,
    CONSTRAINT [PK_PlayerHistory] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_PlayerHistory_gameweekId] FOREIGN KEY ([gameweekId]) REFERENCES [dbo].[Gameweeks] ([id]),
    CONSTRAINT [FK_PlayerHistory_opponent_teamId] FOREIGN KEY ([opponent_teamId]) REFERENCES [dbo].[Teams] ([id]),
    CONSTRAINT [FK_PlayerHistory_playerId] FOREIGN KEY ([playerId]) REFERENCES [dbo].[Players] ([id])
);

GO

--CREATE NONCLUSTERED INDEX [IX_PlayerHistory_fixtureId]
--    ON [dbo].[PlayerHistory]([fixtureId] ASC);
--GO

--CREATE NONCLUSTERED INDEX [IX_PlayerHistory_gameweekId]
--    ON [dbo].[PlayerHistory]([gameweekId] ASC);
--GO

--CREATE NONCLUSTERED INDEX [IX_PlayerHistory_opponent_teamId]
--    ON [dbo].[PlayerHistory]([opponent_teamId] ASC);
--GO

--CREATE NONCLUSTERED INDEX [IX_PlayerHistory_playerId]
--    ON [dbo].[PlayerHistory]([playerId] ASC);
--GO

--CREATE NONCLUSTERED INDEX [IX_PlayerHistory_was_home]
--    ON [dbo].[PlayerHistory]([was_home] ASC)
--    INCLUDE([kickoff_time], [gameweekId], [playerId], [opponent_teamId]);
--GO