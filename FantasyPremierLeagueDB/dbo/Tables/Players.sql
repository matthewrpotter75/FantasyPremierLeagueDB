﻿CREATE TABLE [dbo].[Players] (
    [id]                           INT            NOT NULL,
    [photo]                        VARCHAR (50)   NOT NULL,
    [web_name]                     VARCHAR (50)   NOT NULL,
    [team_code]                    TINYINT        NOT NULL,
    [status]                       CHAR (1)       NOT NULL,
    [code]                         INT            NOT NULL,
    [first_name]                   VARCHAR (50)   NOT NULL,
    [second_name]                  VARCHAR (50)   NOT NULL,
    [squad_number]                 TINYINT        NULL,
    [news]                         VARCHAR (200)  NULL,
    [now_cost]                     TINYINT        NOT NULL,
    [chance_of_playing_this_round] DECIMAL(5,2)   NULL,
    [chance_of_playing_next_round] DECIMAL(5,2)   NULL,
    [value_form]                   DECIMAL (6, 2) NOT NULL,
    [value_season]                 DECIMAL (6, 2) NOT NULL,
    [cost_change_start]            SMALLINT       NOT NULL,
    [cost_change_event]            SMALLINT       NOT NULL,
    [cost_change_start_fall]       SMALLINT       NOT NULL,
    [cost_change_event_fall]       SMALLINT       NOT NULL,
    [in_dreamteam]                 BIT            NOT NULL,
    [dreamteam_count]              TINYINT        NOT NULL,
    [selected_by_percent]          DECIMAL (6, 2) NOT NULL,
    [form]                         DECIMAL (6, 2) NULL,
    [transfers_out]                INT            NOT NULL,
    [transfers_in]                 INT            NOT NULL,
    [transfers_out_event]          INT            NOT NULL,
    [transfers_in_event]           INT            NOT NULL,
    [loans_in]                     TINYINT        NOT NULL,
    [loans_out]                    TINYINT        NOT NULL,
    [loaned_in]                    TINYINT        NOT NULL,
    [loaned_out]                   TINYINT        NOT NULL,
    [total_points]                 SMALLINT       NOT NULL,
    [event_points]                 SMALLINT       NOT NULL,
    [points_per_game]              DECIMAL (4, 2) NOT NULL,
    [ep_this]                      DECIMAL (4, 2) NULL,
    [ep_next]                      DECIMAL (4, 2) NULL,
    [special]                      BIT            NOT NULL,
    [minutes]                      SMALLINT       NOT NULL,
    [goals_scored]                 TINYINT        NOT NULL,
    [assists]                      TINYINT        NOT NULL,
    [clean_sheets]                 TINYINT        NOT NULL,
    [goals_conceded]               TINYINT        NOT NULL,
    [own_goals]                    TINYINT        NOT NULL,
    [penalties_saved]              TINYINT        NOT NULL,
    [penalties_missed]             TINYINT        NOT NULL,
    [yellow_cards]                 TINYINT        NOT NULL,
    [red_cards]                    TINYINT        NOT NULL,
    [saves]                        TINYINT        NOT NULL,
    [bonus]                        TINYINT        NOT NULL,
    [bps]                          SMALLINT       NOT NULL,
    [influence]                    DECIMAL (6, 2) NOT NULL,
    [creativity]                   DECIMAL (6, 2) NOT NULL,
    [threat]                       DECIMAL (6, 2) NOT NULL,
    [ict_index]                    DECIMAL (6, 2) NOT NULL,
    [ea_index]                     SMALLINT       NOT NULL,
    [playerPositionId]             INT        NOT NULL,
    [teamId]                       INT        NOT NULL,
    CONSTRAINT [PK_Players] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_Players_playerPositionId] FOREIGN KEY ([playerPositionId]) REFERENCES [dbo].[PlayerPositions] ([id]),
    CONSTRAINT [FK_Players_teamId] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Teams] ([id])
);
GO

CREATE NONCLUSTERED INDEX [IX_Players_playerPositionId] ON [dbo].[Players] ([playerPositionId]);
GO

CREATE NONCLUSTERED INDEX [IX_Players_teamId] ON [dbo].[Players] ([teamId]);
GO