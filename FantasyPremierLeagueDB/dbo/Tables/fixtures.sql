CREATE TABLE [dbo].[Fixtures] (
    [id]                     INT		   NOT NULL,
    [kickoff_time_formatted] VARCHAR (16)  NULL,
    [event_name]             VARCHAR (16)  NULL,
    [opponent_name]          VARCHAR (50)  NOT NULL,
    [opponent_short_name]    VARCHAR (3)   NOT NULL,
    [is_home]                BIT           NOT NULL,
    [difficulty]             TINYINT       NOT NULL,
    [code]                   INT           NOT NULL,
    [kickoff_time]           SMALLDATETIME NULL,
    [finished]               BIT           NOT NULL,
    [minutes]                TINYINT       NOT NULL,
    [provisional_start_time] BIT           NOT NULL,
    [finished_provisional]   BIT           NOT NULL,
    [gameweekId]             INT		   NULL,
    [team_a]                 INT	       NOT NULL,
    [team_h]                 INT	       NOT NULL,
    CONSTRAINT [PK_fixtures] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_fixtures_gameweekId] FOREIGN KEY ([gameweekId]) REFERENCES [dbo].[Gameweeks] ([id]),
    CONSTRAINT [FK_fixtures_team_a] FOREIGN KEY ([team_a]) REFERENCES [dbo].[Teams] ([id]),
    CONSTRAINT [FK_fixtures_team_h] FOREIGN KEY ([team_h]) REFERENCES [dbo].[Teams] ([id])
);
GO

CREATE NONCLUSTERED INDEX [IX_Fixtures_team_a] ON [dbo].[Fixtures] ([team_a]);
GO

CREATE NONCLUSTERED INDEX [IX_Fixtures_team_h] ON [dbo].[Fixtures] ([team_h]);
GO

CREATE NONCLUSTERED INDEX [IX_Fixtures_gameweekId] ON [dbo].[Fixtures] ([gameweekId]);
GO