CREATE TABLE [dbo].[fixtures_summary] (
    [id]                     INT           NOT NULL,
    [kickoff_time_formatted] VARCHAR (16)  NOT NULL,
    [event_name]             VARCHAR (16)  NOT NULL,
    [opponent_name]          VARCHAR (50)  NOT NULL,
    [opponent_short_name]    VARCHAR (3)   NOT NULL,
    [is_home]                BIT           NOT NULL,
    [difficulty]             TINYINT       NOT NULL,
    [code]                   INT           NOT NULL,
    [kickoff_time]           SMALLDATETIME NOT NULL,
    [finished]               VARCHAR (50)  NOT NULL,
    [minutes]                TINYINT       NOT NULL,
    [provisional_start_time] BIT           NOT NULL,
    [finished_provisional]   BIT           NOT NULL,
    [gameweekId]             TINYINT       NOT NULL,
    [team_a]                 INT       NOT NULL,
    [team_h]                 INT       NOT NULL,
    CONSTRAINT [PK_fixtures_summary] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_fixtures_summary_team_a] FOREIGN KEY ([team_a]) REFERENCES [dbo].[Teams] ([id]),
    CONSTRAINT [FK_fixtures_summary_team_h] FOREIGN KEY ([team_h]) REFERENCES [dbo].[Teams] ([id])
);

