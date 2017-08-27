CREATE TABLE [dbo].[PlayerHistory] (
    [id]                              INT            NOT NULL,
    [kickoff_time]                    SMALLDATETIME  NOT NULL,
    [kickoff_time_formatted]          VARCHAR (16)   NOT NULL,
    [team_h_score]                    TINYINT        NULL,
    [team_a_score]                    TINYINT        NULL,
    [was_home]                        BIT            NOT NULL,
    [gameweekId]                      INT			 NOT NULL,
    [total_points]                    SMALLINT       NOT NULL,
    [value]                           TINYINT        NOT NULL,
    [transfers_balance]               INT            NOT NULL,
    [selected]                        INT            NOT NULL,
    [transfers_in]                    INT            NOT NULL,
    [transfers_out]                   INT            NOT NULL,
    [loaned_in]                       INT			 NOT NULL,
    [loaned_out]                      INT			 NOT NULL,
    [minutes]                         INT			 NOT NULL,
    [goals_scored]                    TINYINT        NOT NULL,
    [assists]                         TINYINT        NOT NULL,
    [clean_sheets]                    TINYINT        NOT NULL,
    [goals_conceded]                  TINYINT        NOT NULL,
    [own_goals]                       TINYINT        NOT NULL,
    [penalties_saved]                 TINYINT        NOT NULL,
    [penalties_missed]                TINYINT        NOT NULL,
    [yellow_cards]                    TINYINT        NOT NULL,
    [red_cards]                       TINYINT        NOT NULL,
    [saves]                           TINYINT        NOT NULL,
    [bonus]                           TINYINT        NOT NULL,
    [bps]                             SMALLINT       NOT NULL,
    [influence]                       DECIMAL (6, 2) NOT NULL,
    [creativity]                      DECIMAL (6, 2) NOT NULL,
    [threat]                          DECIMAL (6, 2) NOT NULL,
    [ict_index]                       DECIMAL (6, 2) NOT NULL,
    [ea_index]                        SMALLINT       NOT NULL,
    [open_play_crosses]               TINYINT        NOT NULL,
    [big_chances_created]             TINYINT        NOT NULL,
    [clearances_blocks_interceptions] TINYINT        NOT NULL,
    [recoveries]                      TINYINT        NOT NULL,
    [key_passes]                      TINYINT        NOT NULL,
    [tackles]                         TINYINT        NOT NULL,
    [winning_goals]                   TINYINT        NOT NULL,
    [attempted_passes]                TINYINT        NOT NULL,
    [completed_passes]                TINYINT        NOT NULL,
    [penalties_conceded]              TINYINT        NOT NULL,
    [big_chances_missed]              TINYINT        NOT NULL,
    [errors_leading_to_goal]          TINYINT        NOT NULL,
    [errors_leading_to_goal_attempt]  TINYINT        NOT NULL,
    [tackled]                         TINYINT        NOT NULL,
    [offside]                         TINYINT        NOT NULL,
    [target_missed]                   TINYINT        NOT NULL,
    [fouls]                           TINYINT        NOT NULL,
    [dribbles]                        TINYINT        NOT NULL,
    [playerId]                        INT            NOT NULL,
    [fixtureId]                       INT		     NOT NULL,
    [opponent_teamId]                 INT			 NOT NULL,
    CONSTRAINT [PK_PlayerHistory] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_PlayerHistory_gameweekId] FOREIGN KEY ([gameweekId]) REFERENCES [dbo].[Gameweeks] ([id]),
    CONSTRAINT [FK_PlayerHistory_opponent_teamId] FOREIGN KEY ([opponent_teamId]) REFERENCES [dbo].[Teams] ([id]),
	CONSTRAINT [FK_PlayerHistory_playerId] FOREIGN KEY ([playerId]) REFERENCES [dbo].[Players] ([id])
);
GO

CREATE NONCLUSTERED INDEX [IX_PlayerHistory_playerId] ON [dbo].[PlayerHistory] ([playerId]);
GO

CREATE NONCLUSTERED INDEX [IX_PlayerHistory_fixtureId] ON [dbo].[PlayerHistory] ([fixtureId]);
GO

CREATE NONCLUSTERED INDEX [IX_PlayerHistory_gameweekId] ON [dbo].[PlayerHistory] ([gameweekId]);
GO

CREATE NONCLUSTERED INDEX [IX_PlayerHistory_opponent_teamId] ON [dbo].[PlayerHistory] ([opponent_teamId]);
GO