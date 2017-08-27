CREATE TABLE [dbo].[fixture] (
    [id]                      SMALLINT      NOT NULL,
    [kickoff_time_formatted]  VARCHAR (16)  NOT NULL,
    [started]                 BIT           NOT NULL,
    [event_day]               TINYINT       NOT NULL,
    [deadline_time]           SMALLDATETIME NOT NULL,
    [deadline_time_formatted] VARCHAR (16)  NOT NULL,
    [code]                    INT           NOT NULL,
    [kickoff_time]            SMALLDATETIME NOT NULL,
    [team_h_score]            TINYINT       NULL,
    [team_a_score]            TINYINT       NULL,
    [finished]                BIT           NOT NULL,
    [minutes]                 TINYINT       NOT NULL,
    [provisional_start_time]  BIT           NOT NULL,
    [finished_provisional]    BIT           NOT NULL,
    [gameweekId]              INT	        NOT NULL,
    [team_a]                  INT	        NOT NULL,
    [team_h]                  INT	        NOT NULL,
    CONSTRAINT [PK_fixture] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_fixture_event] FOREIGN KEY ([gameweekId]) REFERENCES [dbo].[Gameweeks] ([id]),
    CONSTRAINT [FK_fixture_team_a] FOREIGN KEY ([team_a]) REFERENCES [dbo].[Teams] ([id]),
    CONSTRAINT [FK_fixture_team_h] FOREIGN KEY ([team_h]) REFERENCES [dbo].[Teams] ([id])
);

